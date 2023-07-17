package integration

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

import (
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

// AssertExample tests that a deployed instance of dynamic-web-app behaves as expected.
func AssertExample(t *testing.T) {
	example := tft.NewTFBlueprintTest(t)
	ah := utils.NewAssertHTTP()

	// Runs after terraform apply.
	example.DefineApply(func(a *assert.Assertions) {
		example.DefaultApply(a)

		// This module deploys a 'placeholder' Firebase Hosting release early
		// in the process, to prevent a "Site Not Found" displaying when Terraform
		// has finished applying, but the deployment is not yet complete.
		//
		// This extension of apply is meant to emulate that behavior. We confirm
		// the placeholder behavior here to boost confidence that the frontend test in
		// example.DefineVerify proves the placeholder page is replaced.
		//
		// If the check is flaky, remove it in favor of
		// a simpler HTTP request.
		//
		// https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/64
		firebaseURL := terraform.OutputRequired(t, example.GetTFOptions(), "firebase_url")
		t.Log("Firebase Hosting should be running at ", firebaseURL)
		t.Run("Placeholder Site", verifyURL(ah, firebaseURL, "Your application is still deploying"))
	})

	// Verify tests terraform apply outcomes.
	example.DefineVerify(func(a *assert.Assertions) {
		example.DefaultVerify(a)

		projectID := example.GetTFSetupStringOutput("project_id")
		t.Logf("Using Project ID %q", projectID)

		// Check that the Cloud Storage API is enabled
		t.Run("Project", func(t *testing.T) {
			services := gcloud.Run(t, "services list", gcloud.WithCommonArgs([]string{"--project", projectID, "--format", "json"})).Array()
			match := utils.GetFirstMatchResult(t, services, "config.name", "storage.googleapis.com")
			a.Equal("ENABLED", match.Get("state").String(), "storage service should be enabled")
		})
		// Check that the Avocano API is ready and serving
		serverServiceName := terraform.OutputRequired(t, example.GetTFOptions(), "server_service_name")
		clientJobName := terraform.OutputRequired(t, example.GetTFOptions(), "client_job_name")
		region := example.GetTFOptions().Vars["region"].(string)
		t.Logf("Running test in region %s", region)
		if region == "" {
			t.Fatal("Could not parse region from terraform options")
		}
		t.Run("Avocano API", testAvocanoAPI(a, ah, projectID, region, serverServiceName, clientJobName))

		// Check that the Avocano front page is deployed to Firebase Hosting and serving
		firebaseURL := terraform.OutputRequired(t, example.GetTFOptions(), "firebase_url")
		t.Log("Firebase Hosting should be running at ", firebaseURL)
		t.Run("Avocano Frontend", verifyURL(ah, firebaseURL, "<title>Avocano</title>"))
	})

	example.Test()
}

// verifyURL simplifies HTTP asserts for simple GET requests.
func verifyURL(ah *utils.AssertHTTP, url string, want ...string) func(t *testing.T) {
	return func(t *testing.T) {
		t.Helper()
		r, err := http.NewRequest(http.MethodGet, url, nil)
		if err != nil {
			t.Fatal(err)
		}
		ah.AssertResponseWithRetry(t, r, http.StatusOK, want...)
	}
}

// testAvocanoAPI confirms the Cloud Run server backend is ready.
func testAvocanoAPI(a *assert.Assertions, ah *utils.AssertHTTP, projectID string, region string, serviceName string, jobName string) func(t *testing.T) {
	return func(t *testing.T) {
		t.Helper()

		// Look up the Cloud Run API server
		cloudRunServices := gcloud.Run(t, "run services list", gcloud.WithCommonArgs([]string{"--filter", "metadata.name=" + serviceName, "--project", projectID, "--format", "json"})).Array()
		nbServices := len(cloudRunServices)
		a.Equal(1, nbServices, "we expected a single Cloud Run service called %s to be deployed, found %d services", serviceName, nbServices)

		// Load the API server URL
		match := utils.GetFirstMatchResult(t, cloudRunServices, "kind", "Service")
		serviceURL := match.Get("status.url").String()
		a.Truef(strings.HasSuffix(serviceURL, ".run.app"), "unexpected service URL %q", serviceURL)
		t.Log("Cloud Run service is running at", serviceURL)

		// The Cloud Run service is the app's API backend.
		t.Run("Serving", verifyURL(ah, serviceURL, "/api", "/admin"))

		// The API database is populated by Cloud Run Jobs that are run sequentionally.
		// Wait for the final job to finish before testing API behavior.
		// The job is recognized as finished by the presence of a completion time.
		t.Run("Database", func(t *testing.T) {
			isJobFinished := func() (bool, error) {
				clientJobExecs := gcloud.Run(t, "run jobs executions list", gcloud.WithCommonArgs([]string{"--filter", "metadata.name~" + jobName, "--project", projectID, "--region", region, "--format", "json"})).Array()

				if len(clientJobExecs) == 0 {
					t.Log("No Cloud Run job execution found. Retrying...")
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
				a.NotEqual(completionTime, "", "completedTime must have a value")

				succeededCount := match.Get("status.succeededCount").Int()
				a.Equal(succeededCount, int64(1), "succeededCount must not be 0")

				return false, nil
			}
			utils.Poll(t, isJobFinished, 10, time.Second*10)
		})

		// The API must return a list that includes our flagship product
		flagshipProduct := "Sparkly Avocado"
		t.Run("Seeded Data", verifyURL(ah, serviceURL+"/api/products/", flagshipProduct))
	}
}
