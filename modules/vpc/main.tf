resource "aws_vpc" "vpc-identifier" {
  cidr_block           = var.vpc_identifier_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-identifier"
  }
}

resource "aws_internet_gateway" "igw-identifier" {
  vpc_id = aws_vpc.vpc-identifier.id

  tags = {
    Name = "igw-identifier"
  }
}

resource "aws_route_table" "rtb-identifier-lb" {
  vpc_id = aws_vpc.vpc-identifier.id

  route {
    cidr_block = var.rtb_identifier_lb_cidr_block
    gateway_id = aws_internet_gateway.igw-identifier.id
  }

  tags = {
    Name = "rtb-identifier-lb"
  }
}

resource "aws_route_table" "rtb-identifier-ap" {
  vpc_id = aws_vpc.vpc-identifier.id

  route {
    cidr_block = var.rtb_identifier_ap_cidr_block
    nat_gateway_id = aws_nat_gateway.nat-identifier.id
  }

  tags = {
    Name = "rtb-identifier-ap"
  }
}

resource "aws_route_table" "rtb-identifier-db" {
  vpc_id = aws_vpc.vpc-identifier.id

  tags = {
    Name = "rtb-identifier-db"
  }
}

resource "aws_subnet" "subnet-identifier-lb-a" {
  vpc_id                  = aws_vpc.vpc-identifier.id
  cidr_block              = var.subnet_identifier_lb_a_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "subnet-identifier-lb-a"
  }

  depends_on = ["aws_internet_gateway.igw-identifier"]
}

resource "aws_route_table_association" "rtbassoc-identifier-lb-a" {
  subnet_id      = aws_subnet.subnet-identifier-lb-a.id
  route_table_id = aws_route_table.rtb-identifier-lb.id
}

resource "aws_subnet" "subnet-identifier-lb-c" {
  vpc_id                  = aws_vpc.vpc-identifier.id
  cidr_block              = var.subnet_identifier_lb_c_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = "subnet-identifier-lb-c"
  }

  depends_on = ["aws_internet_gateway.igw-identifier"]
}

resource "aws_route_table_association" "rtbassoc-identifier-lb-c" {
  subnet_id      = aws_subnet.subnet-identifier-lb-c.id
  route_table_id = aws_route_table.rtb-identifier-lb.id
}

resource "aws_subnet" "subnet-identifier-ap-a" {
  vpc_id                  = aws_vpc.vpc-identifier.id
  cidr_block              = var.subnet_identifier_ap_a_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "subnet-identifier-ap-a"
  }

  depends_on = ["aws_internet_gateway.igw-identifier"]
}

resource "aws_route_table_association" "rtbassoc-identifier-ap-a" {
  subnet_id      = aws_subnet.subnet-identifier-ap-a.id
  route_table_id = aws_route_table.rtb-identifier-ap.id
}

resource "aws_subnet" "subnet-identifier-ap-c" {
  vpc_id                  = aws_vpc.vpc-identifier.id
  cidr_block              = var.subnet_identifier_ap_c_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = "subnet-identifier-ap-c"
  }

  depends_on = ["aws_internet_gateway.igw-identifier"]
}

resource "aws_route_table_association" "rtbassoc-identifier-ap-c" {
  subnet_id      = aws_subnet.subnet-identifier-ap-c.id
  route_table_id = aws_route_table.rtb-identifier-ap.id
}

resource "aws_subnet" "subnet-identifier-db-a" {
  vpc_id                  = aws_vpc.vpc-identifier.id
  cidr_block              = var.subnet_identifier_db_a_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "subnet-identifier-db-a"
  }

  depends_on = ["aws_internet_gateway.igw-identifier"]
}

resource "aws_route_table_association" "rtbassoc-identifier-db-a" {
  subnet_id      = aws_subnet.subnet-identifier-db-a.id
  route_table_id = aws_route_table.rtb-identifier-db.id
}

resource "aws_subnet" "subnet-identifier-db-c" {
  vpc_id                  = aws_vpc.vpc-identifier.id
  cidr_block              = var.subnet_identifier_db_c_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = "subnet-identifier-db-c"
  }

  depends_on = ["aws_internet_gateway.igw-identifier"]
}

resource "aws_route_table_association" "rtbassoc-identifier-db-c" {
  subnet_id      = aws_subnet.subnet-identifier-db-c.id
  route_table_id = aws_route_table.rtb-identifier-db.id
}

resource "aws_eip" "eip-identifier-nat" {
  vpc        = true
  depends_on = ["aws_internet_gateway.igw-identifier"]
}

resource "aws_nat_gateway" "nat-identifier" {
  allocation_id = aws_eip.eip-identifier-nat.id
  subnet_id     = aws_subnet.subnet-identifier-lb-a.id

  tags = {
    Name = "eip-identifier-nat"
  }

  depends_on = ["aws_internet_gateway.igw-identifier"]
}

