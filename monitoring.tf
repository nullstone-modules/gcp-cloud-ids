data "ns_connection" "notification" {
  name     = "notification"
  contract = "datastore/gcp/notification"
  optional = true
}

locals {
  notification_name = try(data.ns_connection.notification.outputs.notification_name, "")
}

locals {
  # Builds: jsonPayload.alert_severity=("MEDIUM" OR "HIGH" OR "CRITICAL")
  severity_expr = format(
    "jsonPayload.alert_severity=(%s)",
    join(" OR ", [for s in var.alert_severities : format("%q", s)])
  )

  base_log_filter = join(
    "\nAND ",
    compact([
      # Cloud IDS threat log name and resource type
      "logName=\"projects/${local.project_id}/logs/ids.googleapis.com%2Fthreat\"",
      "resource.type=\"ids.googleapis.com/Endpoint\"",
      "resource.labels.id=\"${local.ids_endpoint_name}\"",
      local.severity_expr,
    ])
  )
}

resource "google_logging_metric" "threat_count" {
  count = local.notification_name == "" ? 0 : 1

  name        = "${local.resource_name}-threat-count"
  description = "Counts Cloud IDS threat logs at selected severities."

  filter = local.base_log_filter

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "cloud_ids_threats" {
  count = local.notification_name == "" ? 0 : 1

  display_name = "Cloud IDS threat detected"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Cloud IDS threat count > 0"

    condition_threshold {
      # Log-based metrics appear in Monitoring under logging.googleapis.com/user/<metric-name>
      filter          = "resource.type=\"ids.googleapis.com/Endpoint\" metric.type=\"logging.googleapis.com/user/${google_logging_metric.threat_count[0].name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      # “Any threats in the last minute” style alert
      duration = "60s"

      aggregations {
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_NONE"
        alignment_period     = "60s"
        group_by_fields      = []
      }
    }
  }

  notification_channels = [local.notification_name]

  documentation {
    content   = <<EOT
Cloud IDS detected one or more threats.

Project: ${local.project_id}
Endpoint: ${local.ids_endpoint_id}
Severities: ${join(", ", var.alert_severities)}

See Cloud Logging:
- logName: ids.googleapis.com/threat
- resource.type: ids.googleapis.com/Endpoint
EOT
    mime_type = "text/markdown"
  }
}
