data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = base64decode(google_container_cluster.primary.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster.primary.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    client_certificate     = base64decode(google_container_cluster.primary.master_auth.0.client_certificate)
    client_key             = base64decode(google_container_cluster.primary.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}

resource "google_compute_address" "lta-address" {
  name         = "lta-address"
  address_type = "EXTERNAL"
  project      = var.gcp_project_id
  region = var.gcp_region
}

resource "google_endpoints_service" "openapi_service" {
  service_name = "lta.endpoints.${var.gcp_project_id}.cloud.goog"
  project      = var.gcp_project_id
  openapi_config = yamlencode({
    swagger = "2.0"
    info = {
      description = "Cloud Endpoints service for MovieGuru"
      title       = "The London Travel Company"
      version     = "1.0.0"
    }
    paths = {}
    host  = "lta.endpoints.${var.gcp_project_id}.cloud.goog"
    x-google-endpoints = [
      {
        name   = "lta.endpoints.${var.gcp_project_id}.cloud.goog"
        target = google_compute_address.lta-address.address
      },
    ]
  })
}


resource "helm_release" "lta" {
  name             = "london-travel-company-app"
  chart            = var.helm_chart
  namespace        = "ltc"
  version          = var.helm_chart_version
  wait             = false
  create_namespace = true

  set = [
    {
      name  = "Config.Image.Repository"
      value = var.repo_prefix
    },
    {
      name ="Config.AgentIP"
      value = google_compute_address.lta-address.address
    },
    {
      name  = "Config.Image.Tag"
      value = var.image_tag
    },
    {
      name  = "Config.projectID"
      value = var.gcp_project_id
    },
    
    {
      name  = "Config.geminiApiLocation"
      value = var.vertexAI_model_location
  }]
}