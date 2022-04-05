// Define Terraform Configuration
terraform {

  backend "s3" {
    bucket = "dmw2151-state"
    key    = "state_files/ephemeral-dbs.tf"
    region = "us-east-1"
  }

  required_version = ">= 1.0.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
}

// Providers
provider "aws" {
  region  = "us-east-1"
  profile = "dmw2151"
}

// [Optional] Created an EBS KMS Key Outside of Terraform. As of writing these cannot be deleted w.o a 7+
// day waiting period. See `./common-0-0/utilities/kms/generate-kms-key.go`
//
// Data: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key
// data "aws_kms_key" "ebs_kms_key" {
//   key_id = "alias/ebs-kms-key"
// }

// Get current IP address; assumes testing/deploying this setup from personal environment
// 
// Data: https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http
data "http" "deployer_ip_addr" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  // Locals for Provisioning Networking in Public Subnets
  sec_grp_ids = [
    for sg in [module.network.vpc_all_traffic_sg, module.network.egress_sg, module.network.deployer_sg, ] : sg.id
  ]
}

//
// Module: Network - Creates the core network for the experiments - Also exports VPC, 
// subnet, SG ids, etc.
//
module "network" {

  // General
  source               = "../modules/core-network"
  module_friendly_name = "Instance Storage DBs"

  // Jump Instance
  jump_instance_availability_zone = "us-east-1a"
  instance_user_data_path         = "./../0-0-common/user-data/init-jump-instance.sh"
  instance_user_data_args         = {}

  // Networking && Security Groups
  default_availability_zones = ["us-east-1a", "us-east-1b"]
  whitelisted_ips            = ["${chomp(data.http.deployer_ip_addr.body)}/32"]
}

// 
// Module: Volumes - Creates an instance with attached volumes - to be used for benchmarking read/write performance 
// of the disk
//
module "volumes" {

  // General
  source               = "../modules/disk-benchmarks"
  module_friendly_name = "EBS Benchmarks"

  // Networking Configuration
  availability_zone           = "us-east-1a"
  instance_security_group_ids = local.sec_grp_ids
  instance_launch_subnet      = module.network.public_subnet["us-east-1a"]

  // Instance Configuration
  instance_type               = "r6gd.xlarge" // Could be `i3en.xlarge`, any instance w. instance storage will do
  benchmarking_utilities_path = "./../0-0-common/utilities/benchmarks/"
  instance_user_data_path     = "./../0-0-common/user-data/init-volume-testing-instance.sh"
  instance_user_data_args     = {}

  // Disk Configuration
  disk_kms_key_id = "" // Optional Argument - EBS can be unencrypted for tests...

  // Include the Following Test Instances (+ Root & Instance Storage):
  //  - io1 - *The* AWS recommended volume for database storage - (~$105/mo)
  //  - gp2 - Older generation, OK burst IOPS and throughput, solid for consistent, low-moderate load (~$8/mo)
  //
  aux_volume_configuration = {
    "gp2-auxillary-volume" : {
      size_in_gb = 200
      type       = "gp2"
      mnt_pnt    = "/dev/sdg"
    }
    "io1-auxillary-volume" : {
      size_in_gb = 200
      type       = "io1"
      iops       = 8000
      mnt_pnt    = "/dev/sdh"
    },
  }

  // Root Volume - Mid-level GP3 (~$30/mo)
  root_volume_configuration = {
    size_in_gb = 128
    type       = "gp3"
    iops       = 8000
    throughput = 1000
  }
}

// 
// Module: PG-Tests - Creates an instance w. attached volumes - to be used for benchmarking the performance
// of PostgreSQL read/writes given different data directories
//
module "pg-tests" {

  // General
  source               = "../modules/disk-benchmarks"
  module_friendly_name = "PG Benchmarks"

  // Networking Configuration
  availability_zone           = "us-east-1a"
  instance_security_group_ids = local.sec_grp_ids
  instance_launch_subnet      = module.network.public_subnet["us-east-1a"]

  // Instance Configuration
  instance_type               = "r6gd.xlarge" // Could be `i3en.xlarge`, any instance w. instance storage will do
  benchmarking_utilities_path = "./../0-0-common/utilities/benchmarks/"
  instance_user_data_path     = "./../0-0-common/user-data/init-std-postgres.sh"
  instance_user_data_args     = {}

  // Instance Disk Configuration
  disk_kms_key_id = "" // Optional Argument - EBS can be unencrypted for tests...

  root_volume_configuration = {
    size_in_gb = 128
    type       = "gp3"
    iops       = 8000
    throughput = 1000
  }
}


//
// Module: Databases - Creates the database instances and the networking resources to allow for
// a cluster of instance-storage hosted DBs
//
module "dbs" {

  // General
  source               = "../modules/instance-storage-dbs"
  module_friendly_name = "Instance DBs"

  // Instance
  instance_ssh_key = "public-jump-1"

  // Networking
  core_vpc           = module.network.vpc
  writer_nlb_subnets = module.network.private_subnet

  // Security Groups 
  vpc_all_traffic_sg = module.network.vpc_all_traffic_sg
  deployer_sg        = module.network.deployer_sg
}
