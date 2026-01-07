output "ltc_address" {
  value = google_cloud_run_v2_service.app.uri
}

output "frontend_address" {
  value = google_cloud_run_v2_service.frontend.uri
}
