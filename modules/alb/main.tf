data "aws_acm_certificate" "acm_yourdomain" {
  types  = ["AMAZON_ISSUED"]
  domain = var.acm_yourdomain
}

resource "aws_lb_target_group" "lb-tg-identifier" {
  name     = "lb-tg-identifier"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_identifier_id
}

resource "aws_lb" "lb-identifier" {
  name               = "lb-identifier"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-identifier-lb.id]
  subnets            = [var.subnet_identifier_lb_a_id, var.subnet_identifier_lb_c_id]

  tags = {
    Name = "lb-identifier"
  }
}

resource "aws_lb_listener_certificate" "lnc-identifier" {
  listener_arn    = aws_lb_listener.ln-identifier.arn
  certificate_arn = data.aws_acm_certificate.acm_yourdomain.arn
}

resource "aws_lb_listener" "ln-identifier-http" {
  load_balancer_arn = aws_lb.lb-identifier.arn
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
  load_balancer_arn = aws_lb.lb-identifier.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.acm_yourdomain.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg-identifier.arn
  }
}

resource "aws_security_group" "sg-identifier-lb" {
  name        = "identifier-lb"
  description = "Allow all https inbound traffic"
  vpc_id      = var.vpc_identifier_id
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

resource "aws_security_group_rule" "sg-identifier-lb-http-ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
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
