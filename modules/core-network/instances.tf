// Just a Jump Server...

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "jump" {

  // General
  ami           = var.jump_instance_ami  // Default: "ami-0c92c94c2ecbd7d9c"
  instance_type = var.jump_instance_type // Default: "t4g.nano"

  // Security + Networking
  subnet_id                   = aws_subnet.public[local.jump_instance_subnet].id
  availability_zone           = aws_subnet.public[local.jump_instance_subnet].availability_zone
  associate_public_ip_address = true
  key_name                    = var.jump_instance_ssh_keyname
  vpc_security_group_ids = [
    aws_security_group.allow_deployer_sg.id,
    aws_security_group.allow_http_egress.id,
    aws_security_group.vpc_all_traffic_sg.id
  ]

  // User Data - Miscellaneous Jump Server Utilities
  user_data = templatefile(
    var.instance_user_data_path, var.instance_user_data_args
  )

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Jump"
  }

}