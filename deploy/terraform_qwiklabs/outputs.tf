output "gke-connection-string" {
  value       = "gcloud container clusters get-credentials lta-cluster --region ${var.gcp_region} --project ${var.gcp_project_id}"
  description = "Connection string for the cluster"
}

output "ltc_ip" {
  value = google_compute_global_address.lta-address.address
}


output "lta_address" {
  value = "http://ltc.endpoints.${var.gcp_project_id}.cloud.goog"
}
