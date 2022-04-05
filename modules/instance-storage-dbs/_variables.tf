// Variables


variable "module_friendly_name" {
  description = "Name to append to many tags"
  type        = string
}

// Variable:
variable "instance_ssh_key" {
  description = "SSH key used to connect to testing instance"
  type        = string
  default     = "public-jump-1"
}

variable "core_vpc" {
  description = "Core VPC of the deployment"
  type = object({
    id         = string
    arn        = string
    cidr_block = string
  })
}

// Variable: 
variable "writer_nlb_subnets" {
  description = "Private Subnets for the DB"
  type = map(object({
    id                   = string
    arn                  = string
    availability_zone_id = string
    availability_zone    = string
  }))
}

// Variable:
variable "db_main_availability_zone" {
  description = "..."
  type        = string
  default     = "us-east-1a"
}

// Variable:
variable "vpc_all_traffic_sg" {
  description = "Default decurity group to apply for intra-VPC traffic"
  type = object({
    name = string
    arn  = string
    id   = string
  })
}

// Variable:
variable "deployer_sg" {
  description = "Security group to allow deployer (myself) ssh into the cluster w. SSH from $MY_IPV4"
  type = object({
    name = string
    arn  = string
    id   = string
  })
  sensitive = true
}