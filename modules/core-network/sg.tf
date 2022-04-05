// A Few Simple Security Groups for the Experiments

// A group which allows SSH access from the IP of the System Deployer/Admin
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "allow_deployer_sg" {

  // General
  name                   = "allow_deployer"
  description            = "Allows SSH access from the IP of the System Deployer/Admin"
  revoke_rules_on_delete = true
  vpc_id                 = aws_vpc.core.id

  // Ingress Rules - Allow SSH into instance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.whitelisted_ips
  }

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Allow Deployer SSH (${aws_vpc.core.id})"
  }

}

// A very permissive group that allows all communication within the VPC
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "vpc_all_traffic_sg" {

  // General
  name                   = "vpc_all_traffic_sg"
  description            = "Allows ingress/egress on all ports from within the VPC"
  vpc_id                 = aws_vpc.core.id
  revoke_rules_on_delete = true

  // Ingress/Egress Rules - Allow all connections within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.core.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.core.cidr_block]
  }

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Allow All Intra-VPC (${aws_vpc.core.id})"
  }

}

// A group that allows HTTP/HTTPS egress (i.e. internet access) for resources in private subnets
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "allow_http_egress" {

  // General
  name                   = "allow_https_core_egress"
  description            = "Allow HTTP/HTTPS egress (i.e. internet access) for resources in private subnets"
  revoke_rules_on_delete = true
  vpc_id                 = aws_vpc.core.id

  // Ingress/Egress Rules
  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Allow HTTP(S) Egress (${aws_vpc.core.id})"
  }

}