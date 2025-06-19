module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  project_id   = var.gcp_project_id
  network_name = "lta-vpc"

  subnets = [
    {
      subnet_name   = "lta-cluster-subnet"
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.gcp_region
    },
  ]
  bgp_best_path_selection_mode = "STANDARD"


}
