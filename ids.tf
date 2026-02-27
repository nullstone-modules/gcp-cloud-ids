resource "google_cloud_ids_endpoint" "this" {
  name     = local.resource_name
  location = local.available_zones[0]
  network  = local.vpc_id
  severity = var.threat_severity

  depends_on = [
    google_project_service.ids_api,
    google_project_service.servicenetworking_api
  ]
}

resource "google_compute_packet_mirroring" "ids_mirroring" {
  name = local.resource_name

  network {
    url = local.vpc_id
  }

  collector_ilb {
    url = google_cloud_ids_endpoint.this.endpoint_forwarding_rule
  }

  mirrored_resources {
    dynamic "subnetworks" {
      for_each = toset(concat(local.private_subnets_ids, local.public_subnets_ids))

      content {
        url = subnetworks.value
      }
    }
  }

  filter {
    ip_protocols = ["tcp", "udp", "icmp"]
  }
}

locals {
  ids_endpoint_id   = google_cloud_ids_endpoint.this.id
  ids_endpoint_name = google_cloud_ids_endpoint.this.name
}
