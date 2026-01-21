
resource "google_service_account" "service_account" {
  account_id   = "lta-sa"
  display_name = "lta"
  project      = var.gcp_project_id
}

resource "google_storage_bucket_iam_member" "bucket_reader_otel" {
  bucket = google_storage_bucket.otel.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}
resource "google_storage_bucket_iam_member" "bucket_reader_db" {
  bucket = google_storage_bucket.db_file.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}


resource "google_project_iam_member" "vertex-user" {
  project = var.gcp_project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "run-invoker" {
  project = var.gcp_project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "monitoring-writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "trace-agent" {
  project = var.gcp_project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "log-writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "telemetry-writer" {
  project = var.gcp_project_id
  role    = "roles/telemetry.writer"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}