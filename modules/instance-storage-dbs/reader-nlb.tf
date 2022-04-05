// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "pg_reader" {

  // General
  name               = "pg-reader-nlb"
  load_balancer_type = "network"
  internal           = true

  // Network
  subnets = [for subnet in var.writer_nlb_subnets : subnet.id]

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Reader DB Node"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "pg_reader" {

  name        = "pg-reader"
  port        = 5432
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.core_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    port                = "traffic-port"
    protocol            = "TCP"
  }

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Postgres Reader Node"
  }

}



// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "nlb_listener" {

  // General
  load_balancer_arn = aws_lb.pg_reader.arn
  port              = "5432"
  protocol          = "TCP"

  // Default Action
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pg_reader.arn
  }

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Postgres Reader Node"
  }

}