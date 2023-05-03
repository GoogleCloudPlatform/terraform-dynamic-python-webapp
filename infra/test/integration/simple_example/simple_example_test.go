// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package multiple_buckets

import (
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSimpleExample(t *testing.T) {
	example := tft.NewTFBlueprintTest(t)

	example.DefineApply(func(assert *assert.Assertions) {
		example.DefaultApply(assert)

		// Use of this module as part of a Jump Start Solution triggers a URL
		// request when terraform apply completes. This primes the Firebase Hosting
		// CDN with a platform-supplied 404 page.
		//
		// This extension of apply is meant to emulate that behavior. We confirm
		// the 404 behavior here to boost confidence that the frontend test in
		// example.DefineVerify proves the 404 page is fixed.
		//
		// If the check for "Site Not Found" is flaky, remove it in favor of
		// a simpler HTTP request.
		//
		// https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/64
		u := terraform.OutputRequired(t, example.GetTFOptions(), "firebase_url")
		assertResponseContains(assert, u, "Site Not Found")
	})

	example.DefineVerify(func(assert *assert.Assertions) {
		example.DefaultVerify(assert)

		projectID := example.GetTFSetupStringOutput("project_id")
		region := "us-central1"
		t.Logf("Using Project ID %q", projectID)

		{
			// Check that the Cloud Storage API is enabled
			services := gcloud.Run(t, "services list", gcloud.WithCommonArgs([]string{"--project", projectID, "--format", "json"})).Array()
			match := utils.GetFirstMatchResult(t, services, "config.name", "storage.googleapis.com")
			assert.Equal("ENABLED", match.Get("state").String(), "storage service should be enabled")
		}

		{
			// Check that the Cloud Run service is deployed, is serving, and accepts unauthenticated requests
			cloudRunServices := gcloud.Run(t, "run services list", gcloud.WithCommonArgs([]string{"--project", projectID, "--format", "json"})).Array()
			nbServices := len(cloudRunServices)
			assert.Equal(1, nbServices, "we expected a single Cloud Run service to be deployed, found %d services", nbServices)
			match := utils.GetFirstMatchResult(t, cloudRunServices, "kind", "Service")
			serviceURL := match.Get("status.url").String()
			assert.Truef(strings.HasSuffix(serviceURL, ".run.app"), "unexpected service URL %q", serviceURL)
			t.Log("Cloud Run service is running at", serviceURL)

			// The Cloud Run service is the app's API backend (it does not serve the Avocano homepage)
			assertResponseContains(assert, serviceURL, "/api", "/admin")

			// The data is populated by two Cloud Run jobs, so wait for the final job to finish before continuing.
			// A job execution is completed if it has a completed time.
			isJobFinished := func() (bool, error) {
				clientJobExecs := gcloud.Run(t, "beta run jobs executions list ", gcloud.WithCommonArgs([]string{"--filter", "metadata.name~client", "--project", projectID, "--region", region, "--format", "json"})).Array()

				if len(clientJobExecs) == 0 {
					t.Log("Cloud Run job been executed. Retrying...")
					return true, nil
				}

				match := utils.GetFirstMatchResult(t, clientJobExecs, "kind", "Execution")
				completionTime := match.Get("status.completionTime").String()

				if completionTime == "" {
					// retry
					t.Log("Cloud Run job execution hasn't completed. Retrying...")
					return true, nil
				}

				t.Log("Cloud Run job completed", completionTime)
				assert.NotEqual(completionTime, "", "completedTime must have a value")

				succeededCount := match.Get("status.succeededCount").Int()
				assert.Equal(succeededCount, int64(1), "succeededCount must not be 0")

				return false, nil
			}
			utils.Poll(t, isJobFinished, 10, time.Second*10)

			// The API must return a list that includes our flagship product
			assertResponseContains(assert, serviceURL+"/api/products/", "Sparkly Avocado")
		}
		{
			// Check that the Avocano front page is deployed to Firebase Hosting, and serving
			firebaseURL := fmt.Sprintf("https://%s.web.app", projectID)
			assertResponseContains(assert, firebaseURL, "<title>Avocano</title>")
		}
	})
	example.Test()
}

func assertResponseContains(assert *assert.Assertions, url string, text ...string) {
	code, responseBody, err := httpGetRequest(url)
	assert.Nil(err)
	assert.GreaterOrEqual(code, 200)
	assert.LessOrEqual(code, 299)
	for _, fragment := range text {
		assert.Containsf(responseBody, fragment, "couldn't find %q in response body", fragment)
	}
}

func httpGetRequest(url string) (statusCode int, body string, err error) {
	res, err := http.Get(url)
	if err != nil {
		return 0, "", err
	}
	buffer, err := io.ReadAll(res.Body)
	res.Body.Close()
	return res.StatusCode, string(buffer), err
}
