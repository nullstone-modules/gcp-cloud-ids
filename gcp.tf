data "google_project" "this" {}
data "google_compute_zones" "available" {}

locals {
  project_id      = data.google_project.this.project_id
  available_zones = sort(data.google_compute_zones.available.names)
}

resource "google_project_service" "ids_api" {
  project            = local.project_id
  service            = "ids.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "servicenetworking_api" {
  project            = local.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}
