variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "repo_prefix" {
  type        = string
  description = "Docker/Artifact registry prefix"
  default     = "us-central1-docker.pkg.dev/o11y-movie-guru/london-travel-agency"
}

variable "image_tag" {
  description = "TAG of the movie guru docker images"
  default     = "obslab-v4"
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


variable "branch_name" {
  type        = string
  description = "value of the branch for cloud build trigger"
  default     = "main"
}

variable "otel_file" {
  type = string

  description = "URL of the otel config"
  default     = "https://raw.githubusercontent.com/MKand/movie-guru/refs/heads/main/utils/metrics/otel.values.yaml"
}
variable "db_file" {
  type = string

  description = "URL of the sqllite db file"
  default = "https://raw.githubusercontent.com/MKand/the-london-travel-company/main/data_london/london_travel.sql"
}

variable "service_account_key_file" {
 type = string
}
