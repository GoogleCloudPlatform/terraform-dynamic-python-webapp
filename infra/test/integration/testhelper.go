package test

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

func AssertExample(t *testing.T) {
	example := tft.NewTFBlueprintTest(t)

	example.DefineApply(func(assert *assert.Assertions) {
		example.DefaultApply(assert)

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

		firebase_url := terraform.OutputRequired(t, example.GetTFOptions(), "firebase_url")
		t.Log("Firebase Hosting should be running at ", firebase_url)
		assertResponseContains(t, assert, firebase_url, "Your application is still deploying")
	})

	example.DefineVerify(func(assert *assert.Assertions) {
		example.DefaultVerify(assert)

		projectID := example.GetTFSetupStringOutput("project_id")
		firebase_url := terraform.OutputRequired(t, example.GetTFOptions(), "firebase_url")
		server_service_name := terraform.OutputRequired(t, example.GetTFOptions(), "server_service_name")
		client_job_name := terraform.OutputRequired(t, example.GetTFOptions(), "client_job_name")

		flagshipProduct := "Sparkly Avocado"
		region := "us-central1"
		t.Logf("Using Project ID %q", projectID)

		// Delay to give deploy longer time to complete before app testing.
		t.Log("Delaying to give deploy time to complete. Not always needed.")
		delayUntilServiceDeploy(t, projectID, server_service_name)

		{
			// Check that the expected Cloud Run service is deployed, is serving, and accepts unauthenticated requests
			cloudRunServices := gcloud.Run(t, "run services list", gcloud.WithCommonArgs([]string{"--filter", "metadata.name=" + server_service_name, "--project", projectID, "--format", "json"})).Array()
			nbServices := len(cloudRunServices)
			assert.Equal(1, nbServices, "we expected a single Cloud Run service called %s to be deployed, found %d services", server_service_name, nbServices)
			match := utils.GetFirstMatchResult(t, cloudRunServices, "kind", "Service")
			serviceURL := match.Get("status.url").String()
			assert.Truef(strings.HasSuffix(serviceURL, ".run.app"), "unexpected service URL %q", serviceURL)
			t.Log("Cloud Run service is running at", serviceURL)

			// The Cloud Run service is the app's API backend (it does not serve the Avocano homepage)
			assertResponseContains(t, assert, serviceURL, "/api", "/admin")

			// The data is populated by two Cloud Run jobs, so wait for the final job to finish before continuing.
			// A job execution is completed if it has a completed time.
			isJobFinished := func() (bool, error) {
				clientJobExecs := gcloud.Run(t, "run jobs executions list ", gcloud.WithCommonArgs([]string{"--filter", "metadata.name~" + client_job_name, "--project", projectID, "--region", region, "--format", "json"})).Array()

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
			assertResponseContains(t, assert, serviceURL+"/api/products/", flagshipProduct)
		}
		{
			// Check that the Avocano front page is deployed to Firebase Hosting, and serving
			t.Log("Firebase Hosting should be running at ", firebase_url)
			assertResponseContains(t, assert, firebase_url, "<title>Avocano</title>")
		}
	})
	example.Test()
}

func assertResponseContains(t *testing.T, assert *assert.Assertions, url string, text ...string) {
	t.Helper()
	var code int
	var responseBody string
	var err error

	fn := func() (bool, error) {
		code, responseBody, err = httpGetRequest(url)
		return code != 200, nil
	}
	utils.Poll(t, fn, 36, 10)

	// Assert expectations of the last checked response.
	assert.Nil(err)
	assert.GreaterOrEqual(code, 200)
	assert.LessOrEqual(code, 299)
	for _, fragment := range text {
		assert.Containsf(responseBody, fragment, "couldn't find %q in response body", fragment)
	}
}

func assertErrorResponseContains(t *testing.T, assert *assert.Assertions, url string, wantCode int, text string) {
	t.Helper()

	code, responseBody, err := httpGetRequest(url)
	assert.Nil(err)
	assert.Equal(code, wantCode)
	assert.Containsf(responseBody, text, "couldn't find %q in response body", text)
}

func httpGetRequest(url string) (statusCode int, body string, err error) {
	res, err := http.Get(url)
	if err != nil {
		return 0, "", err
	}
	defer res.Body.Close()

	buffer, err := io.ReadAll(res.Body)
	return res.StatusCode, string(buffer), err
}

// delayUntilServiceDeploy gives a 1 minute delay, then polls until Cloud Run service deploy.
// The application may still be starting on completion of this delay.
func delayUntilServiceDeploy(t *testing.T, projectID string, serviceName string) {
	time.Sleep(time.Minute)
	fn := func() (bool, error) {
		percent := gcloud.Run(t, "run services list", gcloud.WithCommonArgs([]string{"--filter", "metadata.name=" + serviceName, "--project", projectID, "--format", "value(status.traffic.percent)"})).Int()
		return percent != 100, nil
	}
	utils.Poll(t, fn, 24, 10)
}
