output "ids_endpoint_id" {
  value       = local.ids_endpoint_id
  description = "string ||| The ID of the Cloud IDS endpoint (Format: projects/{{project}}/locations/{{location}}/endpoints/{{name}})"
}

output "ids_endpoint_name" {
  value       = local.ids_endpoint_name
  description = "string ||| The name of the Cloud IDS endpoint"
}
