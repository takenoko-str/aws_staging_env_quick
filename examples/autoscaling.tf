variable "subnet_identifier_ap_a" {}
variable "subnet_identifier_ap_c" {}
variable "iam_instance_profile" {}
variable "aws_account_number" {}
variable "target_group_arn" {}
variable "sg_identifier_ap" {}
variable "instance_type" {}
variable "ami_name" {}
variable "key_name" {}

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

  owners = ["${var.aws_account_number}"]
}

data "aws_subnet" "subnet_identifier_ap_c" {
  id = "${var.subnet_identifier_ap_c}"
}

data "aws_subnet" "subnet_identifier_ap_a" {
  id = "${var.subnet_identifier_ap_a}"
}

data "aws_security_group" "sg_identifier_ap" {
  id = "${var.sg_identifier_ap}"
}

resource "aws_launch_configuration" "lc-identifier" {
  name                 = "lc-identifier-${var.ami_name}"
  image_id             = "${data.aws_ami.ubuntu.id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}"
  security_groups      = ["${data.aws_security_group.sg_identifier_ap.id}"]
  ebs_optimized        = true
  iam_instance_profile = "${var.iam_instance_profile}"
  spot_price           = "0.1"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "as-identifier" {
  name                 = "as-identifier-${var.ami_name}"
  launch_configuration = "${aws_launch_configuration.lc-identifier.name}"
  min_size             = 0
  max_size             = 2

  vpc_zone_identifier = [
    "${data.aws_subnet.subnet_identifier_ap_a.id}",
    "${data.aws_subnet.subnet_identifier_ap_c.id}",
  ]

  target_group_arns = ["${var.target_group_arn}"]

  tag = {
    key                 = "Name"
    value               = "as-identifier-${var.ami_name}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Environment"
    value               = "develop"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Type"
    value               = "API"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}