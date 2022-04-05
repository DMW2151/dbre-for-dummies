//
// Create Route Tables for Testing Environment
//

// Create a Route Table -> Public Route Table -> Enable Internet Connectivity
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "main" {

  // General
  vpc_id = aws_vpc.core.id

  // Routes - IPV4 and IPV6: Subnet <-> Internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.core.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.core.id
  }

  // Tags
  tags = {
    Name = "${var.module_friendly_name} Main Route Table (${aws_vpc.core.id})"
  }

}

// Associate the Route Table to the VPC
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_main_route_table_association" "main" {

  // General
  vpc_id         = aws_vpc.core.id
  route_table_id = aws_route_table.main.id

}