# Init

This folder contains the source for a container image that runs the tasks required to setup the application on first deployment.

The container is designed to be executed as a Cloud Run job, with the `roles/run.developer` role, to run the `init-execute.sh` script:

 * execute the `setup` job, [primes the the database](https://github.com/GoogleCloudPlatform/avocano/blob/main/server/scripts/prime_database.sh) script
 * execute the `client` job, that runs the [client deployment](https://github.com/GoogleCloudPlatform/avocano/blob/main/client/docker-deploy.sh)
 * purges cache and warms API.

