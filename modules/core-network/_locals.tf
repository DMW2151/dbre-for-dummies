locals {

  // Used for Subnet Creation && Routing
  enum_availability_zones = { for i, az in var.default_availability_zones : az => i }
  jump_instance_subnet    = var.default_availability_zones[0]
  n_total_subnets         = 2 * length(local.enum_availability_zones)
  n_public_subnets        = length(local.enum_availability_zones)
}