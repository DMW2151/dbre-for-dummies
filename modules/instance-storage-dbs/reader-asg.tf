
resource "aws_placement_group" "dist" {
  name     = "dist-pg"
  strategy = "spread"
}

# Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "dbs" {

  # Basic
  name                 = "pg-readers-asg"
  launch_configuration = aws_launch_configuration.reader.name

  # Scaling Rules => Min, Max, and Desired Instances - Infrastructure Cap
  min_size         = 2
  desired_capacity = 2
  max_size         = 5

  # Health
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  placement_group           = aws_placement_group.dist.id

  # Security + Networking
  vpc_zone_identifier = [for subn in var.writer_nlb_subnets : subn.id]
  target_group_arns   = [aws_lb_target_group.pg_reader.arn]

  # Tags - Defined as Single Blocks for `aws_autoscaling_group`
  tag {
    key                 = "Name"
    value               = "${var.module_friendly_name} - DB Reader Instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Launched By"
    value               = "DB Reader ASG"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      checkpoint_delay = 300
    }
  }
}