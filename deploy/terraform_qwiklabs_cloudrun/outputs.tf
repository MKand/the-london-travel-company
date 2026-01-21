output "backend_address" {
  value = google_cloud_run_v2_service.backend.uri
}

output "frontend_address" {
  value = google_cloud_run_v2_service.frontend.uri
}
