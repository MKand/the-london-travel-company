resource "google_apphub_application" "lta" {
  location       = "global"
  application_id = "london-travel-agent"
  scope {
    type = "GLOBAL"
  }
}
