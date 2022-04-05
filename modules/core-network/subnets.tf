

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public" {

  // Create N public Subnets...
  for_each = local.enum_availability_zones

  // General
  vpc_id                  = aws_vpc.core.id
  cidr_block              = cidrsubnet(aws_vpc.core.cidr_block, local.n_total_subnets, each.value)
  availability_zone       = each.key
  map_public_ip_on_launch = true

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Public Subnet (${each.key})"
  }
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "private" {

  // Create N private Subnets...
  for_each = local.enum_availability_zones

  // General 
  vpc_id                  = aws_vpc.core.id
  cidr_block              = cidrsubnet(aws_vpc.core.cidr_block, local.n_total_subnets, each.value + local.n_public_subnets)
  availability_zone       = each.key
  map_public_ip_on_launch = false

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Private Subnet (${each.key})"
  }
}
