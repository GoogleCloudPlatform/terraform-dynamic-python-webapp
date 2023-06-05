# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Execute with "docker run --build-arg PROJECT_ID=$PROJECT_ID ..."
ARG PROJECT_ID=YOURPROJECTID
FROM gcr.io/$PROJECT_ID/firebase

RUN apk add gettext
RUN npm install -g json
COPY . ./

ENTRYPOINT ./placeholder-deploy.sh
