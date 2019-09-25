#
# Configuration for Autoscaling group.
#

data "aws_ami" "ubuntu" {
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

data "aws_iam_instance_profile" "instance_profile_identifier_ap" {
  name = var.instance_profile_identifier_ap
}

resource "aws_launch_configuration" "lc-identifier" {
  name                 = "lc-identifier-${var.ami_name}"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  key_name             = var.key_name
  security_groups      = [aws_security_group.sg-identifier-ap.id]
  ebs_optimized        = true
  iam_instance_profile = data.aws_iam_instance_profile.instance_profile_identifier_ap.arn
  spot_price           = var.spot_price

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "lt-identifier" {
  image_id               = data.aws_ami.ubuntu.id
  name                   = "lt-identifier-${var.ami_name}"
  vpc_security_group_ids = [aws_security_group.sg-identifier-ap.id]
  key_name               = var.key_name
  instance_type          = var.instance_type
  #user_data                   = "${base64encode(element(data.template_file.userdata.*.rendered, count.index))}"
  iam_instance_profile {
    name = data.aws_iam_instance_profile.instance_profile_identifier_ap.arn
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

data "aws_sns_topic" "sns_topic" {
  name = var.sns_topic_name
}

resource "aws_autoscaling_group" "asg-identifier" {
  name                      = "asg-identifier-${var.ami_name}"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 100
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 5
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.lt-identifier.id
        version            = "$$Latest"
      }
    }
  }

  vpc_zone_identifier = [
    var.subnet_identifier_ap_a_id,
    var.subnet_identifier_ap_c_id,
  ]

  target_group_arns = [var.lb_tg_identifier_arn]

  tags = [{
    key                 = "Name"
    value               = "asg-identifier-${var.ami_name}"
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

resource "aws_sqs_queue" "graceful_termination_queue_identifier" {
  name = "graceful_termination_queue_identifier"
}

resource "aws_iam_role" "autoscaling_role_identifier" {
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

resource "aws_iam_role_policy" "lifecycle_hook_autoscaling_policy_identifier" {
  name = "lifecycle_hook_autoscaling_policy_identifier"
  role = aws_iam_role.autoscaling_role_identifier.id

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

resource "aws_autoscaling_lifecycle_hook" "asg_hook_identifier" {
  name                    = "asg_hook_identifier"
  autoscaling_group_name  = aws_autoscaling_group.asg-identifier.name
  notification_target_arn = aws_sqs_queue.graceful_termination_queue_identifier.arn
  role_arn                = aws_iam_role.autoscaling_role_identifier.arn
  default_result          = "ABANDON"
  heartbeat_timeout       = 300
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
}

resource "aws_autoscaling_policy" "asg_policy_identifier" {
  name        = "asg_policy_identifier"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_utilization
  }
  estimated_instance_warmup = var.estimated_warmup_time
  autoscaling_group_name    = aws_autoscaling_group.asg-identifier.name
}

resource "aws_autoscaling_notification" "asg_notification_identifier" {
  group_names = [
    aws_autoscaling_group.asg-identifier.name,
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = data.aws_sns_topic.sns_topic.arn
}

resource "aws_security_group" "sg-identifier-ap" {
  name        = "identifier-ap"
  description = "Allow all https inbound traffic"
  vpc_id      = var.vpc_identifier_id
  tags = {
    Name = "identifier-ap"
  }
}

resource "aws_security_group_rule" "sg-identifier-ap-http-ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-identifier-ap.id
}

resource "aws_security_group_rule" "sg-identifier-all-egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-identifier-ap.id
}
