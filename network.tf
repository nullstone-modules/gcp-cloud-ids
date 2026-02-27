data "ns_connection" "network" {
  name     = "network"
  contract = "network/gcp/vpc"
}

locals {
  vpc_id              = data.ns_connection.network.outputs.vpc_id
  private_subnets_ids = try(data.ns_connection.network.outputs.private_subnets_ids, [])
  public_subnets_ids  = try(data.ns_connection.network.outputs.public_subnets_ids, [])
}
