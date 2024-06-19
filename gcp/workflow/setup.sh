#!/bin/bash
#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#------------------------------------------------------------------------------

# causes the shell to exit if any subcommand or pipeline returns a non-zero status
# (free us of checking exitcode after every command)
set -e
echo -e "\033[0;31mWARNING: this script is obsolete, please use gcp/setup.sh.\033[0m"

enable_api() {
  gcloud services enable compute.googleapis.com
  gcloud services enable workflows.googleapis.com
  gcloud services enable workflowexecutions.googleapis.com
  gcloud services enable cloudscheduler.googleapis.com
}

# enable API
enable_api

PROJECT_ID=$(gcloud config get-value project 2> /dev/null)
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="csv(projectNumber)" | tail -n 1)
# be default Cloud Worflows run under the Compute Engine default service account:
SERVICE_ACCOUNT=$PROJECT_NUMBER-compute@developer.gserviceaccount.com

# create completion topic
TOPIC=gaarf_wf_completed
TOPIC_EXISTS=$(gcloud pubsub topics list --filter="name.scope(topic):'$TOPIC'" --format="get(name)")
if [[ ! -n $TOPIC_EXISTS ]]; then
  gcloud pubsub topics create $TOPIC
fi

# deploy WF
./deploy.sh $@

# grant the default service account with read permissions on Cloud Storage
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role=roles/storage.objectViewer
# grant the default service account with execute permissions on Cloud Functions gen1 (CF)
#gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role=roles/cloudfunctions.invoker
# grant the default service account with execute permissions on Cloud Functions gen2 (CF)
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role=roles/run.invoker
# grant the default service account with write permissions on Cloud Logging
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role=roles/logging.logWriter
# grant the default service account with view permissions (cloudfunctions.functions.get) on CF
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role=roles/cloudfunctions.viewer
# grant the default service account with execute permissions on Cloud Workflow (this is for Scheduler which also runs under the default GCE SA)
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role roles/workflows.invoker
# grant the default service account with permissions on to publish pubsub messages
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT --role roles/pubsub.admin #topics.publish
