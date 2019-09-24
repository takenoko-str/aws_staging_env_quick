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

  owners = ["${var.ami_ower_account_id}"]
}

data "aws_subnet" "subnet_identifier_ap_c" {
  id = "${var.subnet_identifier_ap_c}"
}

data "aws_subnet" "subnet_identifier_ap_a" {
  id = "${var.subnet_identifier_ap_a}"
}

data "aws_iam_instance_profile" "instance_profile_identifier_ap" {
  name = "${var.instance_profile_identifier_ap}"
}

resource "aws_launch_configuration" "lc-identifier" {
  name                 = "lc-identifier-${var.ami_name}"
  image_id             = "${data.aws_ami.ubuntu.id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.sg-identifier-ap.id}"]
  ebs_optimized        = true
  iam_instance_profile = "${data.aws_iam_instance_profile.instance_profile_identifier_ap.arn}"
  spot_price           = "0.1"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "as-identifier" {
  name                      = "as-identifier-${var.ami_name}"
  launch_configuration      = "${aws_launch_configuration.lc-identifier.name}"
  min_size                  = 0
  max_size                  = 2
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true

  vpc_zone_identifier = [
    "${data.aws_subnet.subnet_identifier_ap_a.id}",
    "${data.aws_subnet.subnet_identifier_ap_c.id}",
  ]

  target_group_arns = ["${var.lb_tg_identifier_arn}"]

  tags = [{
      key                 = "Name"
      value               = "as-identifier-${var.ami_name}"
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

resource "aws_sqs_queue" "graceful_termination_queue" {
  name = "graceful_termination_queue"
}

resource "aws_iam_role" "autoscaling_role" {
  name = "autoscaling_role"

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

resource "aws_iam_role_policy" "lifecycle_hook_autoscaling_policy" {
  name = "lifecycle_hook_autoscaling_policy"
  role = "${aws_iam_role.autoscaling_role.id}"

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
  autoscaling_group_name  = "${aws_autoscaling_group.as-identifier.name}"
  notification_target_arn = "${aws_sqs_queue.graceful_termination_queue.arn}"
  role_arn                = "${aws_iam_role.autoscaling_role.arn}"
  default_result          = "ABANDON"
  heartbeat_timeout       = 300
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
}

resource "aws_autoscaling_policy" "asg_policy_identifier" {
  name                   = "asg_policy_identifier"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.as-identifier.name}"
}

resource "aws_autoscaling_notification" "asg_notification" {
  group_names = [
    "${aws_autoscaling_group.as-identifier.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${var.sns_topic_arn}"
}

resource "aws_security_group" "sg-identifier-ap" {
  name        = "identifier-ap"
  description = "Allow all https inbound traffic"
  vpc_id      = "${var.vpc_identifier}"
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

