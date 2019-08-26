variable "acm_yourdomain" {}
variable "subnet_identifier_lb_a" {}
variable "subnet_identifier_lb_c" {}
variable "sg_identifier_lb" {}
variable "vpc_identifier" {}


data "aws_acm_certificate" "acm_yourdomain" {
  types = ["AMAZON_ISSUED"]
  domain = "${var.acm_yourdomain}"
}

data "aws_subnet" "subnet_identifier_lb_c" {
  id = "${var.subnet_identifier_lb_c}"
}

data "aws_subnet" "subnet_identifier_lb_a" {
  id = "${var.subnet_identifier_lb_a}"
}

data "aws_security_group" "sg_identifier_lb" {
  id = "${var.sg_identifier_lb}"
}

data "aws_vpc" "vpc_identifier" {
  id = "${var.vpc_identifier}"
}

resource "aws_lb_target_group" "lb-tg-identifier" {
  name     = "lb-tg-identifier"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc_identifier.id}"
}

resource "aws_lb" "lb-identifier" {
  name               = "lb-identifier"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${data.aws_security_group.sg_identifier_lb.id}"]
  subnets            = ["${data.aws_subnet.subnet_identifier_lb_a.id}", "${data.aws_subnet.subnet_identifier_lb_c.id}"]

  tags {
    Name = "lb-identifier"
  }
}

resource "aws_lb_listener_certificate" "lnc-identifier" {
  listener_arn    = "${aws_lb_listener.ln-identifier.arn}"
  certificate_arn = "${data.aws_acm_certificate.acm_yourdomain.arn}"
}

resource "aws_lb_listener" "ln-identifier-http" {
  load_balancer_arn = "${aws_lb.lb-identifier.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "ln-identifier" {
  load_balancer_arn = "${aws_lb.lb-identifier.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.acm_yourdomain.arn}"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb-tg-identifier.arn}"
  }
}
