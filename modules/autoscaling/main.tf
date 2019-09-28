#
# Configuration for Autoscaling group.
#

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_ower_account_id]
}

data "aws_iam_instance_profile" "ap" {
  name = var.instance_profile_ap
}

resource "aws_placement_group" "this" {
  name     = "pg-identifier-cluster"
  strategy = "cluster"
}

resource "aws_launch_configuration" "this" {
  name                 = "lc-${var.ami_name}"
  image_id             = data.aws_ami.this.id
  instance_type        = var.instance_type
  key_name             = var.key_name
  security_groups      = [aws_security_group.ap.id]
  ebs_optimized        = true
  iam_instance_profile = data.aws_iam_instance_profile.ap.arn
  spot_price           = var.spot_price

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "this" {
  image_id               = data.aws_ami.this.id
  name                   = "lt-${var.ami_name}"
  vpc_security_group_ids = [aws_security_group.ap.id]
  key_name               = var.key_name
  instance_type          = var.instance_type
  #user_data                   = "${base64encode(element(data.template_file.userdata.*.rendered, count.index))}"
  iam_instance_profile {
    name = var.instance_profile_ap
  }
  monitoring {
    enabled = true
  }
  ebs_optimized = true

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_sns_topic" "this" {
  name = var.sns_topic_name
}

resource "aws_autoscaling_schedule" "up" {
  scheduled_action_name  = "up"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
  recurrence             = var.recurrence_start
  autoscaling_group_name = aws_autoscaling_group.ap.name
}

resource "aws_autoscaling_schedule" "down" {
  scheduled_action_name  = "down"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.saved_capacity
  recurrence             = var.recurrence_stop
  autoscaling_group_name = aws_autoscaling_group.ap.name
}

resource "aws_autoscaling_group" "ap" {
  name                      = "identifier-${var.ami_name}"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = "ELB"
  force_delete              = true
  default_cooldown          = var.default_cooldown_time
  metrics_granularity       = "1Minute"
  placement_group           = aws_placement_group.this.id
  enabled_metrics           = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 100
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 5
    }
    launch_template {
      launch_template_specification {
        launch_template_name = aws_launch_template.this.name
      }
    }
  }

  vpc_zone_identifier = [
    var.subnet_ap_a_id,
    var.subnet_ap_c_id,
  ]

  target_group_arns = [var.lb_tg_arn]

  tags = [{
    key                 = "Name"
    value               = "identifier-${var.ami_name}"
    propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "develop"
      propagate_at_launch = true
    },
    {
      key                 = "Type"
      value               = "API"
      propagate_at_launch = true
    }
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_sqs_queue" "this" {
  name = "identifier"
}

resource "aws_iam_role" "this" {
  name = "autoscaling_role_identifier"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  name = "lifecycle_hook_autoscaling_policy_identifier"
  role = aws_iam_role.this.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1436380187000",
            "Effect": "Allow",
            "Action": [
                "sqs:GetQueueUrl",
                "sqs:SendMessage"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_autoscaling_lifecycle_hook" "this" {
  name                    = "identifier"
  autoscaling_group_name  = aws_autoscaling_group.ap.name
  notification_target_arn = aws_sqs_queue.this.arn
  role_arn                = aws_iam_role.this.arn
  default_result          = "ABANDON"
  heartbeat_timeout       = var.heartbeat_timeout
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
}

resource "aws_autoscaling_policy" "this" {
  name        = "asg_policy_identifier"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_utilization
  }
  estimated_instance_warmup = var.estimated_warmup_time
  autoscaling_group_name    = aws_autoscaling_group.ap.name
}

resource "aws_autoscaling_notification" "this" {
  group_names = [
    aws_autoscaling_group.ap.name,
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = data.aws_sns_topic.this.arn
}

resource "aws_security_group" "ap" {
  name        = "identifier-ap"
  description = "Allow all https inbound traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = "identifier-ap"
  }
}

resource "aws_security_group_rule" "ap-http-ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ap.id
}

resource "aws_security_group_rule" "all-egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ap.id
}
