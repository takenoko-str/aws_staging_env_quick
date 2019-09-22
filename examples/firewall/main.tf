variable "s3_bucket_name" {}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket   = "${var.s3_bucket_name}"
    key      = ".terraform/network/terraform.tfstate"
    region   = "ap-northeast-1"
    profile  = "default"
    role_arn = "${var.sts_assume_role_arn}"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "${var.sts_assume_role_arn}"
  }
}

resource "aws_security_group" "sg-identifier-lb" {
  name        = "identifier-lb"
  description = "Allow all https inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  tags = {
    Name = "identifier-lb"
  }
}

resource "aws_security_group_rule" "sg-identifier-lb-https-ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-identifier-lb.id
}

resource "aws_security_group_rule" "sg-identifier-all-egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-identifier-lb.id
}
