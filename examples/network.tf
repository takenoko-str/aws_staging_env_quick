resource "aws_vpc" "vpc-stg-hoge" {
    cidr_block = "10.129.0.0/16"
    enable_dns_hostnames = true
    tags {
        Name = "vpc-stg-hoge"
    }
}

resource "aws_internet_gateway" "igw-stg-hoge" {
  vpc_id = "${aws_vpc.vpc-stg-hoge.id}"

  tags {
    Name = "igw-stg-hoge"
  }
}

resource "aws_route_table" "rtb-stg-hoge-elb" {
  vpc_id = "${aws_vpc.vpc-stg-hoge.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw-stg-hoge.id}"
  }

  tags {
    Name = "rtb-stg-hoge-elb"
  }
}

resource "aws_route_table" "rtb-stg-hoge-ap" {
  vpc_id = "${aws_vpc.vpc-stg-hoge.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat-stg-hoge.id}"
  }

  tags {
    Name = "rtb-stg-hoge-ap"
  }
}

resource "aws_route_table" "rtb-stg-hoge-db" {
  vpc_id = "${aws_vpc.vpc-stg-hoge.id}"

  tags {
    Name = "rtb-stg-hoge-db"
  }
}

resource "aws_subnet" "subnet-stg-hoge-elb-a" {
  vpc_id     = "${aws_vpc.vpc-stg-hoge.id}"
  cidr_block = "10.129.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
  tags {
    Name = "subnet-stg-hoge-elb-a"
  }
  depends_on = ["aws_internet_gateway.igw-stg-hoge"]
}

resource "aws_route_table_association" "rtbassoc-stg-hoge-elb-a" {
  subnet_id      = "${aws_subnet.subnet-stg-hoge-elb-a.id}"
  route_table_id = "${aws_route_table.rtb-stg-hoge-elb.id}"
}

resource "aws_subnet" "subnet-stg-hoge-elb-c" {
  vpc_id     = "${aws_vpc.vpc-stg-hoge.id}"
  cidr_block = "10.129.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "subnet-stg-hoge-elb-c"
  }
  depends_on = ["aws_internet_gateway.igw-stg-hoge"]
}

resource "aws_route_table_association" "rtbassoc-stg-hoge-elb-c" {
  subnet_id      = "${aws_subnet.subnet-stg-hoge-elb-c.id}"
  route_table_id = "${aws_route_table.rtb-stg-hoge-elb.id}"
}

resource "aws_subnet" "subnet-stg-hoge-ap-a" {
  vpc_id     = "${aws_vpc.vpc-stg-hoge.id}"
  cidr_block = "10.129.16.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
  tags {
    Name = "subnet-stg-hoge-ap-a"
  }
  depends_on = ["aws_internet_gateway.igw-stg-hoge"]
}

resource "aws_route_table_association" "rtbassoc-stg-hoge-ap-a" {
  subnet_id      = "${aws_subnet.subnet-stg-hoge-ap-a.id}"
  route_table_id = "${aws_route_table.rtb-stg-hoge-ap.id}"
}

resource "aws_subnet" "subnet-stg-hoge-ap-c" {
  vpc_id     = "${aws_vpc.vpc-stg-hoge.id}"
  cidr_block = "10.129.17.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "subnet-stg-hoge-ap-c"
  }
  depends_on = ["aws_internet_gateway.igw-stg-hoge"]
}

resource "aws_route_table_association" "rtbassoc-stg-hoge-ap-c" {
  subnet_id      = "${aws_subnet.subnet-stg-hoge-ap-c.id}"
  route_table_id = "${aws_route_table.rtb-stg-hoge-ap.id}"
}

resource "aws_subnet" "subnet-stg-hoge-db-a" {
  vpc_id     = "${aws_vpc.vpc-stg-hoge.id}"
  cidr_block = "10.129.56.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
  tags {
    Name = "subnet-stg-hoge-db-a"
  }
  depends_on = ["aws_internet_gateway.igw-stg-hoge"]
}

resource "aws_route_table_association" "rtbassoc-stg-hoge-db-a" {
  subnet_id      = "${aws_subnet.subnet-stg-hoge-db-a.id}"
  route_table_id = "${aws_route_table.rtb-stg-hoge-db.id}"
}

resource "aws_subnet" "subnet-stg-hoge-db-c" {
  vpc_id     = "${aws_vpc.vpc-stg-hoge.id}"
  cidr_block = "10.129.57.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "subnet-stg-hoge-db-c"
  }
  depends_on = ["aws_internet_gateway.igw-stg-hoge"]
}

resource "aws_route_table_association" "rtbassoc-stg-hoge-db-c" {
  subnet_id      = "${aws_subnet.subnet-stg-hoge-db-c.id}"
  route_table_id = "${aws_route_table.rtb-stg-hoge-db.id}"
}

resource "aws_eip" "eip-stg-hoge-nat" {
  vpc = true
  depends_on = ["aws_internet_gateway.igw-stg-hoge"]
}

resource "aws_nat_gateway" "nat-stg-hoge" {
  allocation_id = "${aws_eip.eip-stg-hoge-nat.id}"
  subnet_id     = "${aws_subnet.subnet-stg-hoge-elb-a.id}"
  tags {
    Name = "eip-stg-hoge-nat"
  }
  depends_on = ["aws_internet_gateway.igw-stg-hoge"]
}
