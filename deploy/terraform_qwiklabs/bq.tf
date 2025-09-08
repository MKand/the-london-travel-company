resource "google_bigquery_connection" "default" {
  connection_id = "lab_connection"
  project       = var.gcp_project_id
  location      = "US"
  cloud_resource {}
}

resource "google_project_iam_member" "connectionPermissionGrant" {
  project       = var.gcp_project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_bigquery_connection.default.cloud_resource[0].service_account_id}"
}