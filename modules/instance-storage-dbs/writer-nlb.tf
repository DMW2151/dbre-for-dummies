// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "pg_writer" {

  // General
  name               = "pg-writer-nlb"
  load_balancer_type = "network"
  internal           = true

  // Netwwork
  subnets = [for subnet in var.writer_nlb_subnets : subnet.id]

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Postgres Writer Node"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "pg_writer" {

  // General
  name        = "pg-writer"
  port        = 5432
  protocol    = "TCP"
  target_type = "instance"

  // Networking
  vpc_id = var.core_vpc.id

  // Health
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
    Name = "${var.module_friendly_name} - Postgres Writer Node"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "pg_writer" {

  // General
  port              = "5432"
  protocol          = "TCP"
  load_balancer_arn = aws_lb.pg_writer.arn

  // NOTE: No SSL Here During Testing

  // Default Actions
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pg_writer.arn
  }

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Postgres Writer Node"
  }

}

// Resource:  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.pg_writer.arn
  target_id        = aws_instance.writer.id
  port             = 5432
}