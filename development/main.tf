terraform {
  backend "s3" {
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "module_vpc" {
  vpc_identifier_cidr_block = "${var.vpc_identifier_cidr_block}"
  rtb_identifier_lb_cidr_block = "${var.rtb_identifier_lb_cidr_block}"
  rtb_identifier_ap_cidr_block = "${var.rtb_identifier_ap_cidr_block}"
  subnet_identifier_lb_a_cidr_block = "${var.subnet_identifier_lb_a_cidr_block}"
  subnet_identifier_lb_c_cidr_block = "${var.subnet_identifier_lb_c_cidr_block}"
  subnet_identifier_ap_a_cidr_block = "${var.subnet_identifier_ap_a_cidr_block}"
  subnet_identifier_ap_c_cidr_block = "${var.subnet_identifier_ap_c_cidr_block}"
  subnet_identifier_db_a_cidr_block = "${var.subnet_identifier_db_a_cidr_block}"
  subnet_identifier_db_c_cidr_block = "${var.subnet_identifier_db_c_cidr_block}"
  source = "../modules/vpc"
}

module "module_alb" {
  acm_yourdomain = "${var.acm_yourdomain}"
  subnet_identifier_lb_a = "${module.module_vpc.subnet_identifier_lb_a_id}"
  subnet_identifier_lb_c = "${module.module_vpc.subnet_identifier_lb_c_id}"
  vpc_identifier = "${module.module_vpc.vpc_identifier_id}"
  source = "../modules/alb"
}

