resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-identifier"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw-identifier"
  }
}

resource "aws_route_table" "lb" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.rtb_lb_cidr_block
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "lb"
  }
}

resource "aws_route_table" "ap" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.rtb_ap_cidr_block
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "ap"
  }
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "db"
  }
}

resource "aws_subnet" "lb_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_lb_a_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "lb_a"
  }

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route_table_association" "lb_a" {
  subnet_id      = aws_subnet.lb_a.id
  route_table_id = aws_route_table.lb.id
}

resource "aws_subnet" "lb_c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_lb_c_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = "lb_c"
  }

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route_table_association" "lb_c" {
  subnet_id      = aws_subnet.lb_c.id
  route_table_id = aws_route_table.lb.id
}

resource "aws_subnet" "ap_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_ap_a_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "ap_a"
  }

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route_table_association" "ap_a" {
  subnet_id      = aws_subnet.ap_a.id
  route_table_id = aws_route_table.ap.id
}

resource "aws_subnet" "ap_c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_ap_c_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = "ap_c"
  }

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route_table_association" "ap_c" {
  subnet_id      = aws_subnet.ap_c.id
  route_table_id = aws_route_table.ap.id
}

resource "aws_subnet" "db_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_db_a_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "db_a"
  }

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.db.id
}

resource "aws_subnet" "db_c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_db_c_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = "db_c"
  }

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route_table_association" "db_c" {
  subnet_id      = aws_subnet.db_c.id
  route_table_id = aws_route_table.db.id
}

resource "aws_eip" "eip-identifier-nat" {
  vpc        = true
  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.eip-identifier-nat.id
  subnet_id     = aws_subnet.lb_a.id

  tags = {
    Name = "nat"
  }

  depends_on = ["aws_internet_gateway.this"]
}

