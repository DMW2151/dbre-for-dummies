// Create Core VPC for Disk Testing Experiments

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "core" {

  // General
  cidr_block           = "192.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  // Tags
  tags = {
    Name = "${var.module_friendly_name} VPC"
  }
}