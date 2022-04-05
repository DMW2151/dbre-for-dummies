// Build an AMI w. PostgreSQL 13.1  running on Ubuntu XX.XX
packer {

  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }

}

// Build Variables

// Variable: src_ami_owner
variable "src_ami_owner" {
  type        = string
  description = "AWS ID of Owner of source instance, defaults to Canonical's ID"
  default     = "099720109477"
}


// Variable: 
variable "ubuntu_version" {
  type        = string
  description = "Variable for AWS ID of Owner of source instance, defaults to Canonical's ID"
  default     = "20.04"
}

// Variable: 
variable "postgres_version" {
  type        = string
  description = "..."
  default     = "14.1"
}

// Variable: 
variable "aws_profile" {
  type        = string
  description = "Variable for AWS ID of Owner of source instance, defaults to Canonical's ID"
  default     = "dmw2151"
}

// Variable: 
variable "aws_region" {
  type        = string
  description = "Variable for AWS ID of Owner of source instance, defaults to Canonical's ID"
  default     = "us-east-1"
}


locals {
  root_instance_name = "ubuntu/images/hvm-ssd/ubuntu-focal-${var.ubuntu_version}-arm64-server-*"
}

// Source: https://www.packer.io/plugins/builders/amazon/instance
// Expect: ami-0b49a4a6e8e22fa16 
source "amazon-ebs" "ubuntu-pg-node" {

  // General
  ami_name      = "ubuntu-${var.ubuntu_version}-postgresql-${var.postgres_version}"
  ssh_username  = "ubuntu"
  instance_type = "r6g.xlarge" 
  region        = "${var.aws_region}"
  profile       = "${var.aws_profile}"

  // Start with Recent Ubuntu 20.04 ARM Instance
  source_ami_filter {

    // Filter for Following:
    filters = {
      name                = local.root_instance_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    // Owner...
    most_recent = true
    owners      = ["${var.src_ami_owner}"]

  }

  tags = {
    OS_Version = "Ubuntu"
    Release    = "Latest"
  }

}

// Builds...
build {
  name        = "ubuntu-pg-node"
  description = "This build creates images for Ubuntu..."

  sources = [
    "source.amazon-ebs.ubuntu-pg-node"
  ]

  provisioner "shell" {
    script = "./../0-0-common/user-data/provision-postgres.sh"
  }

}
