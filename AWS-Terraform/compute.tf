# ---------------------------------------------------------------------------
# Latest Amazon Linux 2023 AMI via the public SSM parameter (no hardcoded ID).
# This is read by Terraform using your credentials; the instances don't need
# any permissions for it.
# ---------------------------------------------------------------------------

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ---------------------------------------------------------------------------
# Launch template describing each WordPress instance.
# ---------------------------------------------------------------------------

resource "aws_launch_template" "wordpress" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type
  key_name      = var.key_name

  # Optional instance profile. In AWS Academy Learner Lab you CANNOT create
  # roles, but a pre-made one usually exists (commonly "LabInstanceProfile").
  # Leave instance_profile_name = null (the default) and the fleet still works
  # and serves the site; set it only if you want SSM Session Manager access and
  # have confirmed the name with: aws iam list-instance-profiles
  dynamic "iam_instance_profile" {
    for_each = var.instance_profile_name == null ? [] : [1]
    content {
      name = var.instance_profile_name
    }
  }

  vpc_security_group_ids = [aws_security_group.ec2.id]

  # Enforce IMDSv2.
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    db_endpoint = aws_db_instance.wordpress.address
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = random_password.db.result
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-wordpress"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Auto Scaling Group across both private subnets, attached to the ALB.
# ---------------------------------------------------------------------------

resource "aws_autoscaling_group" "wordpress" {
  name                      = "${var.project_name}-asg"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = aws_subnet.private[*].id
  target_group_arns         = [aws_lb_target_group.wordpress.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  # Roll instances when the launch template changes (e.g. new AMI).
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-wordpress"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Simple target-tracking scaling policy (CPU 60%).
# ---------------------------------------------------------------------------

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.project_name}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.wordpress.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}
