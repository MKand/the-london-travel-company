module "cft_create_space" {
  source   = "terraform-google-modules/gcloud/google"
  platform = "linux"

  create_cmd_entrypoint    = "chmod +x ${path.module}/0_cft-create_space.sh; ${path.module}/0_cft-create_space.sh"
  create_cmd_body          = var.gcp_project_id
  skip_download            = false
  upgrade                  = false
  module_depends_on        = [google_project_service.enable_apis]
  service_account_key_file = var.service_account_key_file
}

module "cft_google_components" {
  source   = "terraform-google-modules/gcloud/google"
  platform = "linux"

  create_cmd_entrypoint    = "chmod +x ${path.module}/1_cft-google-components.sh; ${path.module}/1_cft-google-components.sh"
  create_cmd_body          = var.gcp_project_id
  skip_download            = false
  upgrade                  = false
  module_depends_on        = [module.cft_create_space]
  service_account_key_file = var.service_account_key_file

}

module "cft_components_connections" {
  source                = "terraform-google-modules/gcloud/google"
  platform              = "linux"
  
  skip_download         = false
  upgrade               = false
  create_cmd_entrypoint = "cd ${path.module}/adc_scripts; chmod +x 2_cft-components-connections.sh; ./2_cft-components-connections.sh"
  create_cmd_body       = var.gcp_project_id
  service_account_key_file = var.service_account_key_file
  module_depends_on = [module.cft_google_components]
}
