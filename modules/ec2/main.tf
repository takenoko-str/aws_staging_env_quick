#
# Security Group
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

resource "aws_security_group" "this" {
  name   = "identifier-bastion"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  description = "identifier-bastion"
}

# EC2
resource "aws_instance" "this" {
  ami                     = data.aws_ami.this.id
  instance_type           = var.instance_type
  disable_api_termination = false
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.this.id]
  subnet_id               = var.subnet_lb_a_id

  tags = {
    Name = "bastion-for-asg"
  }
}

resource "aws_eip" "this" {
  instance = "${aws_instance.this.id}"
  vpc      = true
}