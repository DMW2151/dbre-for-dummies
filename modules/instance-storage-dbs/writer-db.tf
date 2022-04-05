
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "writer" {

  // General
  ami           = data.aws_ami.db.id // Use the PostgreSQL AMI From Packer...
  instance_type = "r6gd.medium"

  // Security + Networking
  associate_public_ip_address = false
  key_name                    = var.instance_ssh_key
  vpc_security_group_ids      = [var.vpc_all_traffic_sg.id]

  subnet_id         = local.primary_db_subnet.id
  availability_zone = local.primary_db_subnet.availability_zone

  // User Data Moves to NVME...
  user_data = templatefile(
    "./../0-0-common/user-data/init-db-primary.sh", {
      vpc_cidr_block = var.core_vpc.cidr_block,
    }
  )

  // Lifecycle rules - This shouldn't matter too much - this instance is a 
  // single point of failure...
  lifecycle {
    create_before_destroy = true
  }

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Primary DB Node"
  }

}