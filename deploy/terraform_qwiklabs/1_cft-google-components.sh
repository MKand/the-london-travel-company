SPACE_ID="default-space"
CATALOG_ID="default-catalog"
export PROJECT_ID=$1

echo "Setting up environment for Project: ${PROJECT_ID}"
gcloud config set project $PROJECT_ID


#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# 1. Endpoints-dns
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID \
      --catalog-id=$CATALOG_ID \
      --catalog-template-id="endpoints-dns" \
      --display-name="Cloud Endpoints DNS" \
      --description="This module creates a DNS record on the .cloud.goog domain using Cloud Endpoints."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID \
      --catalog-id=$CATALOG_ID \
      --catalog-template-id="endpoints-dns" \
      --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-endpoints-dns" \
      --ref-tag="v3.0.1" \
      --dir="/" \
      --branch="main" \
      --roles="roles/servicemanagement.admin,roles/serviceusage.googleapis.com" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53"}]' \
      --terraform-version-constraint=">= 0.13"


# ------------------------------------------------------------------------------
# 2. Datalab
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID \
      --catalog-id=$CATALOG_ID \
      --catalog-template-id="datalab" \
      --display-name="Datalab" \
      --description="Use Cloud Datalab to easily explore, visualize, analyze, and transform data using familiar languages, such as Python and SQL, interactively."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID \
      --catalog-id=$CATALOG_ID \
      --catalog-template-id="datalab" \
      --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-datalab" \
      --ref-tag="v2.0.1" \
      --dir="/" \
      --branch="main" \
      --roles="roles/compute.admin,roles/compute.securityAdmin,roles/iam.serviceAccountUser,roles/iam.serviceAccountAdmin,roles/resourcemanager.projectIamAdmin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 6"}, {"source": "hashicorp/google-beta", "version": ">= 3.53, < 6"}]' \
      --terraform-version-constraint=">= 0.13"

# ------------------------------------------------------------------------------
# 3. Vault
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="vault" \
      --display-name="Vault on GCE" \
      --description="Modular deployment of Vault on Google Compute Engine."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="vault" --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-vault" \
      --ref-tag="v8.0.0" \
      --dir="/" \
      --branch="main" \
      --roles="roles/cloudkms.admin,roles/cloudresourcemanager.organizationViewer,roles/compute.admin,roles/iam.serviceAccountKeyAdmin,roles/iam.serviceAccountAdmin,roles/logging.logWriter,roles/monitoring.metricWriter,roles/monitoring.viewer,roles/storage.legacyBucketReader,roles/storage.objectAdmin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.0.0"}]' \
      --terraform-version-constraint=">= 1.0.0"

# ------------------------------------------------------------------------------
# 4. Project Factory
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="project-factory" \
      --display-name="Project Factory" \
      --description="This component creates projects and configures aspects like Shared VPC connectivity, IAM access, Service Accounts, and API enablement to follow best practices."
  
./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="project-factory" --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-project-factory" \
      --ref-tag="v18.2.0" \
      --roles="roles/billing.projectManager,roles/compute.admin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/resourcemanager.projectIamAdmin,roles/storage.admin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 5.41, < 7"},{"source": "hashicorp/google-beta", "version": ">= 5.41, < 7"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 5. SLO Generator
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="slo-generator" \
      --display-name="SLO Generator" \
      --description="This component allows simplified creation and management of Service Level Objectives (SLOs) and Error Budgets (EBs) using Cloud Monitoring metrics and Cloud Run."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="slo-generator" --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-slo" \
      --ref-tag="v3.1.0" \
      --dir="modules/slo-generator" \
      --roles="roles/monitoring.viewer,roles/monitoring.metricWriter,roles/run.invoker,roles/secretmanager.secretAccessor,roles/storage.admin,roles/cloudrun.admin,roles/cloudscheduler.admin,roles/artifactregistry.admin,roles/monitoring.admin,roles/iam.serviceAccountUser" \
      --provider-versions='[{"source": "hashicorp/google", "version": "> 6.12.0, < 7"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 6. Media CDN VOD
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="media-cdn-vod" \
      --display-name="Media CDN VOD" \
      --description="This module demonstrates deploying a Media CDN Video on Demand solution. It creates two Cloud Storage buckets: vod-upload-<random_suffix>: Upload raw video files here, vod-serving-<random_suffix>: Transcoded video serving bucket. A Google Cloud Function triggers a Transcoder API job convert and package raw video files uploaded to the vod-upload. Transcoded output is written to the vod-serving bucket. A Media CDN service and origin is configured to serve the transcoded output."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="media-cdn-vod" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-media-cdn-vod" \
      --ref-tag="v0.1.0" \
      --roles="roles/storage.admin,roles/artifactregistry.admin,roles/cloudbuild.builds.editor,roles/cloudfunctions.admin,roles/compute.securityAdmin,roles/eventarc.admin,roles/iam.serviceAccountUser,roles/networkservices.admin,roles/pubsub.admin,roles/run.admin,roles/transcoder.admin,roles/serviceusage.serviceUsageAdmin,roles/resourcemanager.projectIamAdmin" \
      --provider-versions='[{"source": "hashicorp/google", "version": "~> 4.27"},{"source": "hashicorp/google-beta", "version": "~> 4.27"}]' \
      --terraform-version-constraint=">= 1.1.9"

# ------------------------------------------------------------------------------
# 7. Data Fusion
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="data-fusion" \
      --display-name="Data Fusion" \
      --description="This module handle opinionated Google Cloud Platform Data Fusion instances."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="data-fusion" --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-data-fusion" \
      --ref-tag="v4.1.0" \
      --roles="roles/datafusion.admin,roles/compute.networkAdmin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 7"}]' \
      --terraform-version-constraint=">= 0.13"


# ------------------------------------------------------------------------------
# 8. Container VM
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="container-vm" \
      --display-name="Container VM Metadata Module" \
      --description="This module handles the generation of metadata for deploying containers on GCE instances."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="container-vm" --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-container-vm" \
      --ref-tag="v3.2.0" \
      --dir="/" \
      --roles="roles/compute.admin,roles/compute.diskAdmin,roles/iam.serviceAccountUser" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 6, < 7"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 9. GKE GitLab
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="gke-gitlab" \
      --display-name="GKE GitLab" \
      --description="This module creates a resilient and fault tolerant GitLab installation using Google Kubernetes Engine (GKE) as the computing environment and the following services for storing data: CloudSQL for PostgreSQL, Memorystore for Redis, Cloud Storage."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="gke-gitlab" --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-gke-gitlab" \
      --ref-tag="v3.0.0" \
      --roles="roles/container.admin,roles/compute.networkAdmin,roles/cloudsql.admin,roles/redis.admin,roles/storage.admin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/resourcemanager.projectIamAdmin,roles/servicenetworking.serviceAgent" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.49, < 5.0"},{"source": "hashicorp/google-beta", "version": ">= 3.49, < 5.0"}]' \
      --terraform-version-constraint=">= 0.13.0"

# ------------------------------------------------------------------------------
# 10. Privileged Access Manager (PAM)
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="pam" \
      --display-name="Privileged Access Manager (PAM)" \
      --description="This module makes it easy to set up Privileged Access Manager (PAM). PAM is a Google Cloud native, managed solution to secure, manage and audit privileged access while ensuring operational velocity and developer productivity."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="pam" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-pam" \
      --ref-tag="v3.1.0" \
      --roles="roles/privilegedaccessmanager.admin,roles/resourcemanager.projectIamAdmin,roles/resourcemanager.folderIamAdmin,roles/resourcemanager.organizationAdmin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.5, < 8"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 11. Self Hosted Terraform Cloud agent on Managed Instance Group Container VMs
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="tfc-agent-mig-container-vm" \
      --display-name="Terraform Cloud Agent on MIG" \
      --description="This module handles the opinionated creation of infrastructure necessary to deploy Terraform Cloud agents on MIG Container VMs."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="tfc-agent-mig-container-vm" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-tf-cloud-agents" \
      --ref-tag="v0.2.0" \
      --dir="modules/tfc-agent-mig-container-vm" \
      --roles="roles/compute.networkAdmin,roles/iam.serviceAccountAdmin,roles/resourcemanager.projectIamAdmin,roles/compute.instanceAdmin,roles/storage.objectViewer,roles/iam.serviceAccountUser" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 7.0.0"},{"source": "hashicorp/google-beta", "version": ">= 3.53, < 7.0.0"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 12. Tags
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="tags" \
      --display-name="Google Cloud Tags" \
      --description="This Terraform module makes it easier to create tags and bind them to different resources/services for your Google Cloud environment."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="tags" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-tags" \
      --ref-tag="v0.3.0" \
      --roles="roles/resourcemanager.tagAdmin,roles/resourcemanager.tagUser" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.48, < 8"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 13. AutoKMS
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="autokey" \
      --display-name="Cloud Auto KMS" \
      --description="Autokey simplifies creating and managing customer encryption keys (CMEK) by automating provisioning and assignment. With Autokey, your key rings, keys, and service accounts do not need to be pre-planned and provisioned. Instead, they are generated on demand as part of resource creation. This module makes it easy to set up Auto KMS."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="autokey" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-autokey" \
      --ref-tag="v1.1.1" \
      --dir="/" \
      --roles="roles/cloudkms.admin,roles/cloudkms.autokeyAdmin,roles/cloudkms.autokeyUser" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.5, < 8"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 14. Dataplex - Auto Data Quality | NO_RELEASE_TAG
# ------------------------------------------------------------------------------
# ./adc.sh --function=create-catalog-template \
#       --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
#       --catalog-template-id="dataplex-auto-data-quality" \
#       --display-name="Dataplex - Auto Data Quality" \
#       --description="Deploy data quality rules on BigQuery tables across development and production environments using Cloud Build."

# ./adc.sh --function=create-catalog-template-revision \
#       --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
#       --catalog-template-id="dataplex-auto-data-quality" --revision-id="r1" \
#       --public-repo-url="GoogleCloudPlatform/terraform-google-dataplex-auto-data-quality" \
#       --ref-tag="v0.1.0" \
#       --dir="modules/deploy" \
#       --roles="roles/bigquery.admin,roles/cloudbuild.builds.editor,roles/dataplex.admin,roles/storage.admin" \
#       --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.83.0, < 6.0.0"},{"source": "hashicorp/google-beta", "version": ">= 4.83.0, < 6.0.0"}]' \
#       --terraform-version-constraint=">= 0.13"


# ------------------------------------------------------------------------------
# 15. NetApp Volumes
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="netapp-volumes" \
      --display-name="NetApp Volumes" \
      --description="This module makes it easy to setup NetApp Volumes. It is designed to deploy Storage Pool and Storage Volume(s). Creation of Storage Pool is optional. Module can create Storage Volme(s) in an existing storage pool."
./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="netapp-volumes" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-netapp-volumes" \
      --ref-tag="v2.1.0" \
      --roles="roles/netapp.admin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.19, < 8"}]' \
      --terraform-version-constraint=">= 1.3.0"

# ------------------------------------------------------------------------------
# 16. Secure Web Proxy
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="secure-web-proxy" \
      --display-name="Secure Web Proxy" \
      --description="This Terraform module simplifies the deployment and management of Secure Web Proxy (SWP) across multiple Google Cloud regions. It handles the creation of SWP gateways, comprehensive policies, and fine-grained rules to control egress web traffic."
./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="secure-web-proxy" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-secure-web-proxy" \
      --ref-tag="v0.1.0" \
      --roles="roles/compute.networkAdmin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 5.1.0, < 6.0"}, {"source": "hashicorp/google-beta", "version": ">= 5.1.0, < 6.0"}]' \
      --terraform-version-constraint=">= 1.3.0"

# ------------------------------------------------------------------------------
# 17. Cloud Deploy
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="cloud-deploy" \
      --display-name="Cloud Deploy" \
      --description="This module is used to create Google Cloud Deploy delivery pipelines, targets and their respective service accounts."
./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="cloud-deploy" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-cloud-deploy" \
      --ref-tag="v0.3.0" \
      --roles="roles/cloudbuild.builds.editor,roles/clouddeploy.developer,roles/container.developer,roles/run.developer,roles/iam.serviceAccountUser" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 7"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 18. Cloud Armor
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="cloud-armor" \
      --display-name="Cloud Armor" \
      --description="This module makes it easy to setup Cloud Armor Global Backend Security Policy with Security rules."
./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="cloud-armor" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-cloud-armor" \
      --ref-tag="v7.0.0" \
      --roles="roles/compute.orgSecurityPolicyAdmin,roles/compute.securityAdmin,roles/recaptchaenterprise.admin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.14, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.14, < 8"}]' \
      --terraform-version-constraint=">= 1.3.0"

# ------------------------------------------------------------------------------
# 19. Cloud IDS
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="cloud-ids" \
      --display-name="Cloud IDS" \
      --description="This module makes it easy to setup Cloud IDS, set up private services access and a packet mirroring policy."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="cloud-ids" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-cloud-ids" \
      --ref-tag="v0.4.0" \
      --roles="roles/ids.admin,roles/compute.packetMirroringUser,roles/logging.viewer" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 8"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 20. Backup and DR
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="backup-dr" \
      --display-name="Backup and DR" \
      --description="This Terraform module helps users provision backup/recovery appliances for their projects and integrate them with the Backup and DR management console."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="backup-dr" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-backup-dr" \
      --ref-tag="v0.5.0" \
      --roles="roles/backupdr.computeEngineOperator,roles/logging.logWriter,roles/iam.serviceAccountUser,roles/cloudkms.cryptoKeyEncrypterDecrypter,roles/cloudkms.admin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.10, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.10, < 8"}, {"source": "hashicorp/random", "version": ">= 3.5.1"}, {"source": "hashicorp/time", "version": ">= 0.9.1"}, {"source": "hashicorp/http", "version": ">= 3.4.0"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 21. GitHub Actions Runner on MIG VM
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="gh-runner-mig-vm" \
      --display-name="Github Actions Runner" \
      --description="This module handles the opinionated creation of infrastructure necessary to deploy Github Self Hosted Runners on MIG."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="gh-runner-mig-vm" --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-github-actions-runners" \
      --ref-tag="v5.1.0" \
      --roles="roles/secretmanager.secretAccessor,roles/owner" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 3.53, < 8"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 22. Ops Agent Policy
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="ops-agent-policy" \
      --display-name="Ops Agent Policy" \
      --description="This module is used to install/uninstall the ops agent in Google Cloud Engine VM using ops agent policies."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="ops-agent-policy" --revision-id="r3" \
      --public-repo-url="terraform-google-modules/terraform-google-cloud-operations" \
      --dir="modules/ops-agent-policy" \
      --ref-tag="v0.6.0" \
      --roles="roles/owner,roles/osconfig.osPolicyAssignmentAdmin,roles/monitoring.metricWriter,roles/logging.logWriter" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.0, < 7"}]' \
      --terraform-version-constraint=">= 0.13"

# ------------------------------------------------------------------------------
# 23. Out-of-Band Security
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="out-of-band-security" \
      --display-name="Out-of-Band Security" \
      --description="This solution aids in the creation and management of scalable Terraform Deployments of VM-based Third Party Security Appliances which inspect mirrored traffic."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="out-of-band-security" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-out-of-band-security" \
      --ref-tag="v0.19.0" \
      --roles="roles/compute.admin" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 6.12"}, {"source": "hashicorp/google-beta", "version": ">= 3.53, < 6.12"}, {"source": "hashicorp/random", "version": ">= 2.2"}]' \
      --terraform-version-constraint=">= 0.13"
  
# ------------------------------------------------------------------------------
# 24. Composer
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="composer" \
      --display-name="Cloud Composer" \
      --description="This module makes it easy to create a Cloud Composer Environment."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="composer" --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-composer" \
      --ref-tag="v6.3.0" \
      --roles="roles/editor,roles/compute.networkAdmin,roles/compute.instanceAdmin.v1,roles/iam.serviceAccountUser,roles/composer.worker" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 3.53, < 8"}]' \
      --terraform-version-constraint=">= 0.13"
  
# ------------------------------------------------------------------------------
# 25. Group
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="group" \
      --display-name="Cloud Identity Group" \
      --description="This module manages Cloud Identity Groups and Memberships using the Cloud Identity Group API."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="group" --revision-id="r1" \
      --public-repo-url="terraform-google-modules/terraform-google-group" \
      --ref-tag="v0.8.0" \
      --roles="roles/serviceusage.serviceUsageConsumer,roles/resourcemanager.organizationViewer" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.67, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 3.67, < 8"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# 26. Secured Data Warehouse
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="secured-data-warehouse" \
  --display-name="Secured Data Warehouse" \
  --description="This solution helps you build a data platform on Google Cloud that is scalable, resilient, and secure by default to store and analyze sensitive data." 
 
./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="secured-data-warehouse" --revision-id="r1" \
  --ref-tag="v0.2.0" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-secured-data-warehouse" \
  --roles="roles/owner,roles/resourcemanager.projectCreator,roles/billing.user" \
  --terraform-version-constraint=">= 0.13" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.61, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 4.61, < 8"}]' 

# ------------------------------------------------------------------------------
# 27. Org Policy
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="org-policy" \
  --display-name="Organization Policy" \
  --description="This Terraform module makes it easy to manage organization policies for your Google Cloud environment, particularly when you want to have exclusion rules." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="org-policy" --revision-id="r1" \
  --ref-tag="v7.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-org-policy" \
  --roles="roles/orgpolicy.policyAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 8"}]' 


# ------------------------------------------------------------------------------
# 28. VPN
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpn" \
  --display-name="Cloud VPN" \
  --description="This module makes it easy to set up VPN connectivity in GCP by defining your gateways and tunnels in a concise syntax."
 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpn" --revision-id="r1" \
  --ref-tag="v6.1.0" \
  --public-repo-url="terraform-google-modules/terraform-google-vpn" \
  --roles="roles/compute.networkAdmin" \
  --terraform-version-constraint=">=1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.30.0, < 8.0"}]' 

# ------------------------------------------------------------------------------
# 29. Network
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="network" \
  --display-name="Cloud VPC Network" \
  --description="This module makes it easy to set up a new VPC Network in GCP by defining your network and subnet ranges in a concise syntax." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="network" --revision-id="r1" \
  --ref-tag="v13.0.0" \
  --public-repo-url="terraform-google-modules/terraform-google-network" \
  --roles="roles/compute.networkAdmin,roles/compute.securityAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.64, < 8.0"}]' 

# ------------------------------------------------------------------------------
# 30. Bastion Host
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="bastion-host" \
  --display-name="Bastion Host" \
  --description="This module will generate a bastion host vm compatible with OS Login and IAP Tunneling that can be used to access internal VMs."

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="bastion-host" --revision-id="r1" \
  --ref-tag="v9.0.0" \
  --public-repo-url="terraform-google-modules/terraform-google-bastion-host" \
  --roles="roles/compute.osLogin,roles/compute.osAdminLogin,roles/compute.osLoginExternalUser" \
  --terraform-version-constraint=">=1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 3.53, < 8.0"}]' 

# ------------------------------------------------------------------------------
# 31. SAP NW
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="sap-nw" \
  --display-name="SAP NW for Google Cloud" \
  --description="This template follows the documented steps https://cloud.google.com/solutions/sap/docs/netweaver-deployment-guide-linux and deploys GCP and Pacemaker resources up to the installation of SAP central services."

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="sap-nw" --revision-id="r1" \
  --ref-tag="v1.0.0" \
  --public-repo-url="terraform-google-modules/terraform-google-sap" \
  --roles="roles/compute.instanceAdmin.v1,roles/compute.networkAdmin" \
  --terraform-version-constraint=">=0.12.6" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.0.0, < 6.0"}]' 

# ------------------------------------------------------------------------------
# 32. IP Address
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="address" \
  --display-name="IP Address" \
  --description="This terraform module provides the means to permanently reserve an IP address available to Google Cloud Platform (GCP) resources, and optionally create forward and reverse entries within Google Cloud DNS."

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="address" --revision-id="r1" \
  --ref-tag="v4.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-address" \
  --roles="roles/dns.admin,roles/compute.networkAdmin" \
  --terraform-version-constraint=">= 0.13" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 5.2.0, < 8.0"}]' 

# ------------------------------------------------------------------------------
# 33. Event Function 
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="event-function" \
  --display-name="Event Function" \
  --description="This module configures a system which responds to events by invoking a Cloud Functions function." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="event-function" --revision-id="r1" \
  --ref-tag="v6.0.0" \
  --public-repo-url="terraform-google-modules/terraform-google-event-function" \
  --roles="roles/cloudfunctions.developer,roles/storage.admin,roles/secretmanager.secretAccessor" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.23, < 8.0"}, {"source": "hashicorp/null", "version": ">= 2.1, < 4.0"}, {"source": "hashicorp/archive", "version": ">= 1.2, < 3.0"}]' 

# ------------------------------------------------------------------------------
# 34. Scheduled Function 
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="scheduled-function" \
  --display-name="Scheduled Function " \
  --description="This modules makes it easy to set up a scheduled job to trigger events/run functions." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="scheduled-function" --revision-id="r1" \
  --ref-tag="v8.0.0" \
  --public-repo-url="terraform-google-modules/terraform-google-scheduled-function" \
  --roles="roles/storage.admin,roles/pubsub.editor,roles/cloudscheduler.admin,roles/cloudfunctions.developer,roles/iam.serviceAccountUser" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.23, < 8.0"}, {"source": "hashicorp/random", "version": ">= 2.1, < 4.0"}]' 

# ------------------------------------------------------------------------------
# 35. GCloud | NOT_NEEDED ?
# ------------------------------------------------------------------------------
# ./adc.sh --function=create-catalog-template \
#   --space-id=$SPACE_ID \
#   --catalog-id=$CATALOG_ID \
#   --catalog-template-id=gcloud \
#   --display-name="terraform-google-gcloud" \
#   --description="This module allows you to use gcloud, gsutil, any gcloud component, and jq in Terraform." \
#   --tags="gcloud, cli, automation"

# ./adc.sh --function=create-catalog-template-revision \
#   --space-id=$SPACE_ID \
#   --catalog-id=$CATALOG_ID \
#   --catalog-template-id=gcloud \
#   --ref-tag=v4.0.0 \
#   --public-repo-url="terraform-google-modules/terraform-google-gcloud" \
#   --roles='[]' \
#   --terraform-version-constraint=">= 1.3" \
#   --provider-versions='["google>=3.53,<8", "external>=2.2.2", "random>=2.1.0", "null>=2.1.0"]'


# ------------------------------------------------------------------------------
# 36. VPC Service Controls
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-service-controls" \
  --display-name="VPC Service Controls" \
  --description="This module handles opinionated VPC Service Controls and Access Context Manager configuration and deployments." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-service-controls" --revision-id="r1" \
  --ref-tag=v7.2.0 \
  --public-repo-url="terraform-google-modules/terraform-google-vpc-service-controls" \
  --roles="roles/accesscontextmanager.policyAdmin,roles/resourcemanager.organizationViewer" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 7.0"}]' 


# ------------------------------------------------------------------------------
# 37. Folders
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="folders" \
  --display-name="Folders" \
  --description="This module helps create several folders under the same parent, enforcing consistent permissions, and with a common naming convention." 


./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="folders" --revision-id="r1"  \
  --ref-tag="v5.1.0" \
  --public-repo-url="terraform-google-modules/terraform-google-folders" \
  --roles="roles/owner,roles/resourcemanager.folderViewer,roles/resourcemanager.projectCreator,roles/compute.networkAdmin,roles/resourcemanager.folderCreator" \
  --terraform-version-constraint=">= 1.3.0" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.0"}]' 


# ------------------------------------------------------------------------------
# 37. Healthcare
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="healthcare" \
  --display-name="Healthcare" \
  --description="This module handles opinionated Google Cloud Platform Healthcare datasets and stores." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="healthcare" --revision-id="r1"  \
  --ref-tag="v3.1.0" \
  --public-repo-url="terraform-google-modules/terraform-google-healthcare" \
  --roles="roles/healthcare.datasetAdmin,roles/healthcare.dicomStoreAdmin,roles/healthcare.fhirStoreAdmin,roles/healthcare.hl7V2StoreAdmin,roles/healthcare.ConsentStoreAdmin,roles/healthcare.pipelineJobsAdmin,roles/bigquery.dataViewer,roles/storage.objectViewer,roles/healthcare.dataMapperWorkspaceAdmin,roles/pubsub.publisher" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 38. Vertex - Feature Online Store
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-feature-online-store" \
  --display-name="Vertex AI Feature Online Store" \
  --description="This module allows you to create and configure a Google Cloud Vertex AI Feature Online Store." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-feature-online-store" --revision-id="r1"  \
  --ref-tag="v2.3.1" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-vertex-ai" \
  --dir="modules/feature-online-store" \
  --roles="roles/aiplatform.admin,roles/compute.admin,roles/compute.networkAdmin,roles/notebooks.admin,roles/iam.securityAdmin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/cloudkms.admin,roles/iam.roleAdmin,roles/storage.admin,roles/cloudkms.cryptoKeyEncrypterDecrypter,roles/modelarmor.admin,roles/modelarmor.floorSettingsAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 39. Vertex - Model Armor Floor Settings
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-model-armor-floorsetting" \
  --display-name="Model Armor Floor Settings" \
  --description="This module is used to create Model Armor floor settings." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-model-armor-floorsetting" --revision-id="r1"  \
  --ref-tag="v2.3.1" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-vertex-ai" \
  --dir="modules/model-armor-floorsetting" \
  --roles="roles/aiplatform.admin,roles/compute.admin,roles/compute.networkAdmin,roles/notebooks.admin,roles/iam.securityAdmin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/cloudkms.admin,roles/iam.roleAdmin,roles/storage.admin,roles/cloudkms.cryptoKeyEncrypterDecrypter,roles/modelarmor.admin,roles/modelarmor.floorSettingsAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 40. Vertex - Model Armor Template
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-model-armor-template" \
  --display-name="Model Armor Template" \
  --description="This module is used to create Model Armor template." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-model-armor-template" \
  --revision-id="r1" \
  --ref-tag="v2.4.1" \
  --public-repo-url="singhalbhaskar/terraform-google-vertex-ai" \
  --dir="modules/model-armor-template" \
  --roles="roles/aiplatform.admin,\
roles/compute.admin,\
roles/compute.networkAdmin,\
roles/notebooks.admin,\
roles/iam.securityAdmin,\
roles/iam.serviceAccountAdmin,\
roles/iam.serviceAccountUser,\
roles/cloudkms.admin,\
roles/iam.roleAdmin,\
roles/storage.admin,\
roles/cloudkms.cryptoKeyEncrypterDecrypter,\
roles/modelarmor.admin,\
roles/modelarmor.floorSettingsAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[
    {"source": "hashicorp/google", "version": ">= 6.6.0, < 8"},
    {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}
  ]'

# ------------------------------------------------------------------------------
# 41. Vertex - Workbench Instance
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-workbench" \
  --display-name="Vertex AI Workbench Instance" \
  --description="This module is used to create Vertex AI Workbench Instance." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-workbench" --revision-id="r1"  \
  --ref-tag="v2.3.1" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-vertex-ai" \
  --dir="modules/workbench" \
  --roles="roles/aiplatform.admin,roles/compute.admin,roles/compute.networkAdmin,roles/notebooks.admin,roles/iam.securityAdmin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/cloudkms.admin,roles/iam.roleAdmin,roles/storage.admin,roles/cloudkms.cryptoKeyEncrypterDecrypter,roles/modelarmor.admin,roles/modelarmor.floorSettingsAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 42. Ops - Simple Uptime Check
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="ops-simple-uptime-check" \
  --display-name="Simple Uptime Check" \
  --description="This module is used to create a single uptime check along with an alert policy and new and/or existing notification channel(s) to notify if the uptime check fails." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="ops-simple-uptime-check" --revision-id="r1"  \
  --ref-tag="v0.6.0" \
  --public-repo-url="terraform-google-modules/terraform-google-cloud-operations" \
  --dir="modules/simple-uptime-check" \
  --roles="roles/monitoring.uptimeCheckConfigEditor,roles/monitoring.alertPolicyEditor,roles/monitoring.notificationChannelEditor" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 43. VPC - Org Policy
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-org-policy" \
  --display-name="VPC Org Policy" \
  --description="The module handles the configuration of access policy. An access policy is globally visible within an organization, and the restrictions it specifies apply to all projects within an organization." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-org-policy" --revision-id="r1"  \
  --ref-tag="v7.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-vpc-service-controls" \
  --dir="/" \
  --roles="roles/accesscontextmanager.policyAdmin,roles/resourcemanager.organizationViewer" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 44. VPC - Access Level
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-access-level" \
  --display-name="VPC Access Level" \
  --description="This module handles opiniated configuration and deployment of access level. An access level is a label that can be applied to requests to GCP services, along with a list of requirements necessary for the label to be applied." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-access-level" --revision-id="r1"  \
  --ref-tag="v7.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-vpc-service-controls" \
  --dir="modules/access_level" \
  --roles="roles/accesscontextmanager.policyAdmin,roles/resourcemanager.organizationViewer" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 45. VPC Bridge Service Perimeter
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-bridge-service-perimeter" \
  --display-name="VPC Bridge Service Perimeter" \
  --description="This module handles opiniated configuration and deployment of a service perimeter for bridge service perimeter types." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-bridge-service-perimeter" --revision-id="r1"  \
  --ref-tag="v7.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-vpc-service-controls" \
  --dir="modules/bridge_service_perimeter" \
  --roles="roles/accesscontextmanager.policyAdmin,roles/resourcemanager.organizationViewer" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 46. VPC Regular Service Perimeter
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-regular-service-perimeter" \
  --display-name="VPC Regular Service Perimeter" \
  --description="This module handles opiniated configuration and deployment of a service perimeter for regular service perimeter types." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vpc-regular-service-perimeter" --revision-id="r1"  \
  --ref-tag="v7.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-vpc-service-controls" \
  --dir="modules/regular_service_perimeter" \
  --roles="roles/accesscontextmanager.policyAdmin,roles/resourcemanager.organizationViewer" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 46. Agent Engine
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="agent-engine" \
  --display-name="Agent Engine" \
  --description="The module creates Agent Engine and related dependencies. It supports both source based deployments (aka in-line deployment) and serialized object deployment (aka pickle deployment)." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="agent-engine" \
  --revision-id="r1" \
  --ref-tag="v1.0" \
  --public-repo-url="singhalbhaskar/agent-engine" \
  --dir="" \
  --roles="roles/aiplatform.user,roles/storage.objectViewer,roles/viewer" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[
    {"source": "hashicorp/google", "version": ">= 7.13.0, < 8"},
    {"source": "hashicorp/google-beta", "version": ">= 7.13.0, < 8"}
  ]'
# ------------------------------------------------------------------------------
# 47. Cloud Router
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-router" \
  --display-name="Cloud Router" \
  --description="This module handles opinionated Google Cloud Platform cloud router configuration. Optionally it can also create cloud nat." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-router" --revision-id="r1"  \
  --ref-tag="v8.1.0" \
  --public-repo-url="terraform-google-modules/terraform-google-cloud-router" \
  --dir="/" \
  --roles="roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/resourcemanager.projectIamAdmin,roles/serviceusage.serviceUsageAdmin,roles/compute.networkAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 48. Cloud Router - Interconnect Attachment
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-router-interconnect-attachment" \
  --display-name="Cloud Router - Interconnect Attachment" \
  --description="Module for Google Cloud Interconnect Attachments (VLAN attachments). It handles the logical connection between a physical Interconnect and a Cloud Router, and optionally configures the BGP peering on that router." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-router-interconnect-attachment" --revision-id="r1"  \
  --ref-tag="v8.1.0" \
  --public-repo-url="terraform-google-modules/terraform-google-cloud-router" \
  --dir="modules/interconnect_attachment" \
  --roles="roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/resourcemanager.projectIamAdmin,roles/serviceusage.serviceUsageAdmin,roles/compute.networkAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 49. Cloud Router - Interface
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-router-interface" \
  --display-name="Cloud Router Interface" \
  --description="This module configures the Layer 3 networking on the Cloud Router." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-router-interface" --revision-id="r1"  \
  --ref-tag="v8.1.0" \
  --public-repo-url="terraform-google-modules/terraform-google-cloud-router" \
  --dir="modules/interface" \
  --roles="roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/resourcemanager.projectIamAdmin,roles/serviceusage.serviceUsageAdmin,roles/compute.networkAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 50. L4 Internal Load Balancer
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="internal-load-balancer" \
  --display-name="Internal Load Balancer" \
  --description="Modular Internal Load Balancer for GCE using forwarding rules." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="internal-load-balancer" --revision-id="r1"  \
  --ref-tag="v7.1.0" \
  --public-repo-url="terraform-google-modules/terraform-google-lb-internal" \
  --dir="/" \
  --roles="roles/owner,roles/compute.networkAdmin,roles/compute.loadBalancerAdmin,roles/compute.securityAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# 51. Artifact Registry
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="artifact-registry" \
  --display-name="Artifact Registry" \
  --description="This module handles the creation of repositories in Artifact Registry on Google Cloud." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="artifact-registry" --revision-id="r1"  \
  --ref-tag="v0.8.2" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-artifact-registry" \
  --dir="/" \
  --roles="roles/artifactregistry.admin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/resourcemanager.projectIamAdmin,roles/serviceusage.serviceUsageAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# ADC 1P Components
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="redis-memorystore" \
  --display-name="Memorystore (Redis)" \
  --description="Memorystore for Redis is a fully managed Redis service for Google Cloud. Applications running on Google Cloud can achieve extreme performance by leveraging the highly scalable, available, secure Redis service without the burden of managing complex Redis deployments." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="redis-memorystore" --revision-id="r1"  \
  --ref-tag="v15.2.1" \
  --public-repo-url="terraform-google-modules/terraform-google-memorystore" \
  --roles="roles/compute.networkAdmin,roles/resourcemanager.projectIamAdmin,roles/serviceusage.serviceUsageAdmin,roles/redis.admin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-run" \
  --display-name="Cloud Run" \
  --description="Cloud Run is a fully managed serverless compute platform that lets you deploy and run containerized applications and jobs. It abstracts away all infrastructure management, automatically scaling your services from zero to handle sudden traffic surges so you can focus on building great applications." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-run" --revision-id="r1"  \
  --ref-tag="v0.21.6" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-cloud-run" \
  --dir="modules/v2" \
  --roles="roles/run.admin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/serviceusage.serviceUsageViewer,roles/resourcemanager.projectIamAdmin,roles/compute.viewer,roles/iap.admin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="postgresql" \
  --display-name="Cloud SQL (Postgresql)" \
  --description="Cloud SQL for PostgreSQL is a fully-managed database service that helps you set up, maintain, manage, and administer your PostgreSQL relational databases on Google Cloud Platform." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="postgresql" --revision-id="r1"  \
  --ref-tag="v26.2.2" \
  --public-repo-url="terraform-google-modules/terraform-google-sql-db" \
  --dir="modules/postgresql" \
  --roles="roles/cloudsql.admin,roles/resourcemanager.projectIamAdmin,roles/iam.serviceAccountUser,roles/compute.networkAdmin,roles/cloudkms.admin,roles/cloudkms.autokeyAdmin,roles/storage.admin,roles/cloudkms.cryptoKeyEncrypterDecrypter,roles/logging.logWriter" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="mysql" \
  --display-name="Cloud SQL (MySQL)" \
  --description="Cloud SQL for MySQL is a fully-managed database service that helps you set up, maintain, manage, and administer your MySQL relational databases on Google Cloud Platform." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="mysql" --revision-id="r1"  \
  --ref-tag="v26.2.2" \
  --public-repo-url="terraform-google-modules/terraform-google-sql-db" \
  --dir="modules/mysql" \
  --roles="roles/cloudsql.admin,roles/resourcemanager.projectIamAdmin,roles/iam.serviceAccountUser,roles/compute.networkAdmin,roles/cloudkms.admin,roles/cloudkms.autokeyAdmin,roles/storage.admin,roles/cloudkms.cryptoKeyEncrypterDecrypter,roles/logging.logWriter" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="service-account" \
  --display-name="Service Account" \
  --description="A service account is a special kind of account typically used by an application or compute workload, such as a Compute Engine instance, rather than a person. A service account is identified by its email address, which is unique to the account." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="service-account" --revision-id="r1"  \
  --ref-tag="v4.6.0" \
  --public-repo-url="terraform-google-modules/terraform-google-service-accounts" \
  --dir="modules/simple-sa" \
  --roles="roles/resourcemanager.projectIamAdmin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/logging.logWriter" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gce-instance-template" \
  --display-name="GCE (Instance Template)" \
  --description="An instance template lets you describe a VM instance. You can then create groups of identical instances based on the template." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gce-instance-template" --revision-id="r1"  \
  --ref-tag="v13.5.0" \
  --public-repo-url="terraform-google-modules/terraform-google-vm" \
  --dir="modules/instance_template" \
  --roles="roles/iam.serviceAccountUser,roles/logging.logWriter,roles/compute.admin,roles/iam.serviceAccountAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gce-mig" \
  --display-name="GCE (Managed Instance Group)" \
  --description="Instance groups are collections of VM instances that use load balancing and automated services, like autoscaling and autohealing. With a Managed Instance Group, you can manage a group of VM instances as one entity.." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gce-mig" --revision-id="r1"  \
  --ref-tag="v13.6.1" \
  --public-repo-url="terraform-google-modules/terraform-google-vm" \
  --dir="modules/mig" \
  --roles="cloudresourcemanager.googleapis.com,compute.googleapis.com,iam.googleapis.com,serviceusage.googleapis.com,storage-api.googleapis.com" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gcs-storage" \
  --display-name="GCS Bucket" \
  --description="Cloud Storage allows world-wide storage and retrieval of any amount of data at any time. You can use Cloud Storage for a range of scenarios including serving website content, storing data for archival and disaster recovery, or distributing large data objects to users via direct download." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gcs-storage" --revision-id="r1"  \
  --ref-tag="v12.0.0" \
  --public-repo-url="terraform-google-modules/terraform-google-cloud-storage" \
  --dir="modules/simple_bucket" \
  --roles="roles/storage.admin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/resourcemanager.projectIamAdmin,roles/serviceusage.serviceUsageAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-ai" \
  --display-name="Vertex AI" \
  --description="Vertex AI is a machine learning (ML) platform that lets you train and deploy ML models and AI applications. Vertex AI combines data engineering, data science, and ML engineering workflows, enabling team collaboration using a common toolset." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-ai" --revision-id="r1"  \
  --ref-tag="v18.0.0" \
  --public-repo-url="terraform-google-modules/terraform-google-project-factory" \
  --dir="modules/project_services" \
  --roles="roles/iam.serviceAccountAdmin,roles/resourcemanager.projectIamAdmin,roles/storage.admin,roles/iam.serviceAccountUser,roles/billing.projectManager,roles/compute.admin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="secret-manager" \
  --display-name="Secret Manager" \
  --description="Secret Manager is a secure and convenient storage system for API keys, passwords, certificates, and other sensitive data." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="secret-manager" --revision-id="r1"  \
  --ref-tag="v0.9.0" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-secret-manager" \
  --dir="modules/simple-secret" \
  --roles="roles/secretmanager.admin,roles/iam.serviceAccountUser,roles/logging.logWriter" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="regional-lb-frontend" \
  --display-name="Regional Load Balancing (Frontend)" \
  --description="Configure the load balancer frontend IP address, port, and protocol. Configure an SSL certificate if using HTTPS." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="regional-lb-frontend" --revision-id="r1"  \
  --ref-tag="v0.6.1" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-regional-lb-http" \
  --dir="modules/frontend" \
  --roles="roles/iam.serviceAccountAdmin,roles/storage.admin,roles/compute.admin,roles/run.admin,roles/iam.serviceAccountUser,roles/certificatemanager.owner,roles/vpcaccess.admin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="regional-lb-backend" \
  --display-name="Regional Load Balancing (Backend)" \
  --description="Create a backend service for incoming traffic." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="regional-lb-backend" --revision-id="r1"  \
  --ref-tag="v0.6.1" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-regional-lb-http" \
  --dir="modules/backend" \
  --roles="roles/vpcaccess.admin,roles/iam.serviceAccountAdmin,roles/storage.admin,roles/compute.admin,roles/run.admin,roles/iam.serviceAccountUser,roles/certificatemanager.owner" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="global-lb-frontend" \
  --display-name="Global Load Balancing (Frontend)" \
  --description="Configure the load balancer frontend IP address, port, and protocol. Configure an SSL certificate if using HTTPS." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="global-lb-frontend" --revision-id="r1"  \
  --ref-tag="v13.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-lb-http" \
  --dir="modules/frontend" \
  --roles="roles/storage.admin,roles/iap.admin,roles/certificatemanager.owner,roles/iam.serviceAccountUser,roles/compute.admin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="global-lb-backend" \
  --display-name="Global Load Balancing (Backend)" \
  --description="Create a backend service for incoming traffic" 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="global-lb-backend" --revision-id="r1"  \
  --ref-tag="v13.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-lb-http" \
  --dir="modules/backend" \
  --roles="roles/compute.admin,roles/storage.admin,roles/run.admin,roles/compute.networkAdmin,roles/iap.admin,roles/iam.serviceAccountUser,roles/iam.serviceAccountAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="bigquery" \
  --display-name="BigQuery" \
  --description="BigQuery is Google Clouds fully managed, petabyte-scale, and cost-effective analytics data warehouse that lets you run analytics over vast amounts of data in near real time." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="bigquery" --revision-id="r1"  \
  --ref-tag="v10.2.1" \
  --public-repo-url="terraform-google-modules/terraform-google-bigquery" \
  --roles="roles/bigquery.admin,roles/storage.admin,roles/cloudkms.cryptoKeyEncrypterDecrypter" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="spanner" \
  --display-name="Cloud Spanner" \
  --description="Cloud Spanner is a fully managed, relational database service that helps you build and manage relational databases for your applications. It offers a wide range of features, including automatic horizontal scaling, strong consistency, and up to 99.999% availability. Cloud spanner is also capable of handling non-relational workloads." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="spanner" --revision-id="r1"  \
  --ref-tag="v1.2.1" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-cloud-spanner" \
  --roles="roles/spanner.admin,roles/resourcemanager.projectIamAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="pubsub" \
  --display-name="Pubsub" \
  --description="Create a pubsub topic and add a subscriptions" 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="pubsub" --revision-id="r1"  \
  --ref-tag="v8.3.2" \
  --public-repo-url="terraform-google-modules/terraform-google-pubsub" \
  --roles="roles/pubsub.admin,roles/resourcemanager.projectIamAdmin,roles/bigquery.admin,roles/storage.admin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="alloydb" \
  --display-name="AlloyDB" \
  --description="AlloyDB is a fully managed PostgreSQL-compatible database for your most demanding enterprise database workloads." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="alloydb" --revision-id="r1"  \
  --ref-tag="v8.0.1" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-alloy-db" \
  --roles="roles/alloydb.admin,roles/cloudkms.admin,roles/cloudkms.autokeyAdmin,roles/cloudkms.cryptoKeyEncrypterDecrypter,roles/compute.admin,roles/dns.admin,roles/resourcemanager.projectIamAdmin,roles/serviceusage.serviceUsageAdmin,roles/servicedirectory.editor,roles/servicenetworking.networksAdmin,roles/storage.admin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="bigtable" \
  --display-name="Bigtable" \
  --description="A highly scalable and serverless NoSQL document database for building managed mobile and web applications with multi-region replication and high availability." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="bigtable" --revision-id="r1"  \
  --ref-tag="v0.4.1" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-bigtable" \
  --roles="roles/cloudkms.admin,roles/iam.serviceAccountAdmin,roles/serviceusage.serviceUsageAdmin,roles/resourcemanager.projectIamAdmin,roles/bigtable.admin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="firestore" \
  --display-name="Firestore" \
  --description="A highly scalable and serverless NoSQL document database for building managed mobile and web applications with multi-region replication and high availability." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="firestore" --revision-id="r1"  \
  --ref-tag="v0.2.2" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-firestore" \
  --roles="roles/datastore.owner,roles/cloudkms.admin,roles/iam.serviceAccountAdmin,roles/serviceusage.serviceUsageAdmin,roles/resourcemanager.projectIamAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gke-node-pool" \
  --display-name="GKE Node Pool" \
  --description="A node pool is a group of nodes within a cluster that have identical configuration and are updated at the same time." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gke-node-pool" --revision-id="r1"  \
  --ref-tag="v41.0.1" \
  --public-repo-url="terraform-google-modules/terraform-google-kubernetes-engine" \
  --dir="modules/gke-node-pool" \
  --roles="roles/compute.admin,roles/container.admin,roles/iam.serviceAccountUser" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gke-autopilot-cluster" \
  --display-name="GKE Autopilot Cluster" \
  --description="A GKE Autopilot cluster is a managed Kubernetes cluster that automatically manages the underlying compute, networking, and storage infrastructure for your applications." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gke-autopilot-cluster" --revision-id="r1"  \
  --ref-tag="v41.0.1" \
  --public-repo-url="terraform-google-modules/terraform-google-kubernetes-engine" \
  --dir="modules/gke-autopilot-cluster" \
  --roles="roles/compute.admin,roles/container.admin,roles/iam.serviceAccountUser" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gke-standard-cluster" \
  --display-name="GKE Standard Cluster" \
  --description="A GKE Standard cluster is a Kubernetes cluster that you can use to run containerized applications." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gke-standard-cluster" --revision-id="r1"  \
  --ref-tag="v41.0.1" \
  --public-repo-url="terraform-google-modules/terraform-google-kubernetes-engine" \
  --dir="modules/gke-standard-cluster" \
  --roles="roles/compute.admin,roles/container.admin,roles/iam.serviceAccountUser" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 
