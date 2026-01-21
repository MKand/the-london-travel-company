resource "google_storage_bucket" "db_file_bucket" {
  name                        = "db-file-${var.gcp_project_id}"
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
}

data "http" "db_file" {
  url = var.db_file
}

resource "google_storage_bucket_object" "db_file_bucket_object" {
  name    = "london_travel.sql"
  bucket  = google_storage_bucket.db_file_bucket.name
  content = data.http.db_file.response_body
}
