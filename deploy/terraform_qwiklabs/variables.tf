variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
  default = "o11y-movie-guru"
}

variable "repo_prefix" {
  type        = string
  description = "Docker/Artifact registry prefix"
  default     = "us-central1-docker.pkg.dev/o11y-movie-guru/london-travel-agency"
}

variable "image_tag" {
  description = "TAG of the movie guru docker images"
  default     = "obslab-v1"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "Region"
}

# Default value passed in
variable "gcp_zone" {
  type        = string
  description = "Zone to create resources in."
  default     = "us-central1-c"
}

variable "vertexAI_model_location" {
  type        = string
  description = "Region from which the vertexAI models are called."
  default     = "us-central1"
}

variable "helm_chart" {
  type        = string
  description = "URL of the movie guru helm char without version"
  default     = "oci://us-central1-docker.pkg.dev/o11y-movie-guru/london-travel-agency/ltc-observability-lab"
}

variable "helm_chart_version" {
  type        = string
  description = "version of the movie guru helm chart. Defaults to 1.0.0"
  default     = "1.0.0"
}

variable "branch_name" {
  type        = string
  description = "value of the branch for cloud build trigger"
  default     = "main"
}
