// Internet gaetway for the Storage testing VPC

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "core" {

  // General
  vpc_id = aws_vpc.core.id

  // Tags
  tags = {
    Name = "Local DBs - IGW"
  }

}