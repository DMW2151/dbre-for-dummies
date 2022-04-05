// Variables

variable "module_friendly_name" {
  description = "Name to append to many tags"
  type        = string
}

// Variable: default_availability_zones - Default Availability Zones for all VPC Resources
variable "default_availability_zones" {
  description = "Default Availability Zones for all VPC Resources"
  default     = ["us-east-1a", "us-east-1b"]
  type        = list(string)
}

// Variable: jump_instance_availability_zone
variable "jump_instance_availability_zone" {
  description = "..."
  type        = string
  default     = "us-east-1a"
}

variable "whitelisted_ips" {
  description = "IP Addresses w. SSH access to the testing instance"
  type        = list(string)
  default     = []
}


variable "instance_user_data_path" {
  description = "..."
  default     = "./../0-0-common/user-data/init-jump-instance.sh"
  type        = string
}

variable "instance_user_data_args" {
  description = "..."
  default     = {}
  type        = map(string)
}


variable "jump_instance_ami" {
  description = "..."
  type        = string
  default     = "ami-0b49a4a6e8e22fa16" // ARM - Ubuntu 20.04 in US-EAST-1
}

variable "jump_instance_type" {
  description = "..."
  type        = string
  default     = "t4g.nano"
}

variable "jump_instance_ssh_keyname" {
  description = "...."
  type        = string
  default     = "public-jump-1"
}