// Variables


// Module Level

variable "module_friendly_name" {
  description = "Name to append to many tags"
  type        = string
}


// Disk Configuration

// Variable: Root Volume Configuration - Configuration for the root volume of the 
// testing instance
variable "root_volume_configuration" {
  description = "Configuration for the root volume of the testing instance"
  type = object({
    size_in_gb = number
    type       = string
    iops       = optional(number)
    throughput = optional(number)
  })
}

// Variable: Volume Configuration - Configuration for supplemental volumes attached 
// to the testing instance
variable "aux_volume_configuration" {
  description = "Configuration for supplemental volumes attached to the testing instance"
  type = map(
    object({
      size_in_gb = number
      type       = string
      iops       = optional(number)
      throughput = optional(number)
      mnt_pnt    = string
    })
  )
  default = {}
}

// Variable: kms_key_id - KMS key used to to encrypt (all) testing volumes
variable "disk_kms_key_id" {
  description = "KMS key used to to encrypt (all) testing volumes"
  type        = string
}


// Network Configuration

// Variable: Availability Zone - The AWS AZ to launch testing resources
variable "availability_zone" {
  description = "The AWS AZ to launch testing resources"
  type        = string
  default     = "us-east-1a"
}

variable "instance_launch_subnet" {
  description = "..."
  type = object({
    id                   = string
    arn                  = string
    availability_zone_id = string
    availability_zone    = string
  })
}


// Instance

// Variable: instance_ami - The AMI of the Root Instance - must be Ubuntu
// for user-data to run properly
variable "instance_ami" {
  description = "The AMI of the testing instance"
  type        = string
  default     = "ami-0b49a4a6e8e22fa16" // Defaults to ARM - Ubuntu 20.04 in us-east-1
}

// Variable: instance_type - Type (and size) to use for the testing instance
variable "instance_type" {
  description = "Type (and size) to use for the testing instance"
  type        = string
  default     = "r6gd.xlarge"
}

// Variable: kms_key_id - KMS key used to to encrypt (all) testing volumes
variable "instance_ssh_key" {
  description = "SSH key used to connect to testing instance"
  type        = string
  default     = "public-jump-1"
}

variable "instance_security_group_ids" {
  description = "...."
  type        = list(string)
}

variable "instance_user_data_path" {
  description = "..."
  default     = "./../0-0-common/user-data/init-volume-testing-instance.sh"
  type        = string
}

variable "instance_user_data_args" {
  description = "..."
  default     = {}
  type        = map(string)
}

// Variable: benchmarking_utilities_path - Directory of scripts to use for benchmarking; these will be SCP'd 
// to the instance
variable "benchmarking_utilities_path" {
  description = "Directory of scripts to use for benchmarking; these will be SCP'd to the instance"
  type        = string
  default     = "../../0-0-common/utilities/benchmarks/"
}
