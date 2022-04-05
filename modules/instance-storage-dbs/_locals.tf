locals {
  primary_db_subnet = var.writer_nlb_subnets[var.db_main_availability_zone]
}