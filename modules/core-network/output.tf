// Outputs
output "vpc" {
  value = aws_vpc.core
}

output "public_subnet" {
  value = aws_subnet.public
}

output "private_subnet" {
  value = aws_subnet.private
}

output "vpc_all_traffic_sg" {
  value = aws_security_group.vpc_all_traffic_sg
}

output "egress_sg" {
  value = aws_security_group.allow_http_egress
}

output "deployer_sg" {
  value = aws_security_group.allow_deployer_sg
}