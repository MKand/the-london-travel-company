resource "google_storage_bucket" "otel" {
  name                        = "otel-config-${var.gcp_project_id}"
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "db_file" {
  name                        = "db-file-${var.gcp_project_id}"
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
}

data "http" "db_file" {
  url = var.db_file
}

data "http" "otel-config" {
  url = var.otel_file
  request_headers = {
    Accept = "application/json"
  }
}

resource "google_storage_bucket_object" "otel" {
  name    = "otel.values.yaml"
  bucket  = google_storage_bucket.otel.name
  content = data.http.otel-config.response_body
}

resource "google_storage_bucket_object" "db-file" {
  name    = "london_travel.sql"
  bucket  = google_storage_bucket.db_file.name
  content = data.http.db_file.response_body
}

resource "google_cloud_run_v2_service" "backend" {
  name     = "londonagent-backend"
  location = var.gcp_region

  template {
    revision = "londonagent-backend-rev1"
    scaling {
      max_instance_count = 1
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.postgres_db.connection_name]
      }
    }
    # Revision-level annotations, including container dependencies
    annotations = {
      "run.googleapis.com/container-dependencies" = jsonencode({
        app = ["collector"]
      })
    }

    service_account = google_service_account.service_account.email
    containers {
      # The main application container
      name  = "london-app"
      image = "${var.repo_prefix}/agent:${var.image_tag}"

      liveness_probe {
        http_get {
          path = "/health"
        }
      }

      ports {
        container_port = 8000
      }

      env {
        name  = "ENABLE_METRICS"
        value = "true"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://localhost:4318"
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.gcp_project_id
      }
      env {
        name  = "GOOGLE_CLOUD_LOCATION"
        value = var.gcp_region
      }
      env {
        name  = "GOOGLE_GENAI_USE_VERTEXAI"
        value = "TRUE"
      }
      env {
        name  = "OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT"
        value = "true"
      }
      env {
        name  = "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED"
        value = "true"
      }
      env {
        name  = "SQLITE_DB_PATH"
        value = "/app/data_london/"
      }
      env {
        name  = "DB_TYPE"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_HOST"
        value = "/cloudsql/${google_sql_database_instance.postgres_db.connection_name}"
      }
      env {
        name  = "POSTGRES_USER"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = random_password.db_password.result
      }
      env {
        name  = "POSTGRES_DB"
        value = "london_activities"
      }

      volume_mounts {
        name       = "db_data"
        mount_path = "/app/data_london/"
      }
    }

    containers {
      name  = "collector"
      image = "us-docker.pkg.dev/cloud-ops-agents-artifacts/google-cloud-opentelemetry-collector/otelcol-google:0.130.0"
      args  = ["--config=/etc/otelcol-google/otel.values.yaml"]

      volume_mounts {
        name       = "config"
        mount_path = "/etc/otelcol-google/"
      }
    }
    volumes {
      name = "config"
      gcs {
        read_only = true
        bucket    = google_storage_bucket.otel.name
      }
    }
    volumes {
      name = "db_data"
      gcs {
        read_only = true
        bucket    = google_storage_bucket.db_file.name
      }
    }
  }
  deletion_protection = false

  depends_on = [google_project_service.enable_apis]
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_v2_service.backend.location
  service  = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

resource "google_cloud_run_v2_service" "frontend" {
  name     = "londonagent-frontend"
  location = var.gcp_region

  template {
    revision = "londonagent-frontend-rev1"
    scaling {
      max_instance_count = 1
    }

    service_account = google_service_account.service_account.email
    containers {
      name  = "london-frontend"
      image = "${var.repo_prefix}/frontend:${var.image_tag}"

      ports {
        container_port = 80
      }

      env {
        name  = "API_BASE_URL"
        value = google_cloud_run_v2_service.backend.uri
      }
    }
  }
  deletion_protection = false

  depends_on = [google_project_service.enable_apis]
}

resource "google_cloud_run_v2_service_iam_binding" "frontend" {
  location = google_cloud_run_v2_service.frontend.location
  name     = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}
