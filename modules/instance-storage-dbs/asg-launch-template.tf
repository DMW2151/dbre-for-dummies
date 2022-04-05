//
//
//

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_launch_configuration" "reader" {

  // General
  image_id      = data.aws_ami.db.id // Use the PostgreSQL AMI From Packer...
  instance_type = "r6gd.medium"      // Set this as needed...
  spot_price    = "0.010"            // Set this as needed...

  // Security + Networking
  associate_public_ip_address = false
  key_name                    = var.instance_ssh_key
  security_groups = [
    var.vpc_all_traffic_sg.id
  ]

  // User Data Moves to NVME...
  user_data = templatefile(
    "./../0-0-common/user-data/init-db-replica.sh", {
      vpc_cidr_block        = var.core_vpc.cidr_block,
      primary_node_hostname = aws_lb.pg_writer.dns_name,
    }
  )

  // Lifecycle Hook
  lifecycle {
    create_before_destroy = true
  }

  // Explicit Dependency on The Writer - Helps w. preventing race
  // condition on first `apply`
  depends_on = [
    aws_instance.writer, aws_lb.pg_writer
  ]


}