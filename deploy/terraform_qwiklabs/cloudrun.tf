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

# data "github_repository_file" "db_file" {
#   repository = "MKand/the-london-travel-company"
#   file       = "data_london/london_travel.db"
#   branch     = "simplify"
# }

data "http" "otel-config" {
  url = var.otel_file
  request_headers = {
    Accept = "application/json"
  }
}

resource "google_storage_bucket_object" "otel" {
  name   = "otel.values.yaml"
  bucket = google_storage_bucket.otel.name
  content = data.http.otel-config.response_body
}

resource "google_storage_bucket_object" "db-file" {
  name   = "london_travel.db"
  bucket = google_storage_bucket.db_file.name
  content = data.http.db_file.response_body
}

resource "google_cloud_run_v2_service" "app" {
  name     = "londonagent-server"
  location = var.gcp_region

  template {
    scaling {
      max_instance_count = 1
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
        name  = "PRINT_HEALTH_STATUS"
        value = "False"
      }
      env {
        name = "DB_PATH"
        value = "/app/data_london/"
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

  depends_on = [ google_project_service.enable_apis ]
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_v2_service.app.location
  service  = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}
