// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "db" {

  //
  owners      = ["self"]
  most_recent = true

  // Filters...
  filter {
    name   = "name"
    values = ["ubuntu-20.04-postgresql-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}

