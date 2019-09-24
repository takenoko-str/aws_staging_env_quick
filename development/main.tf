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
  subnet_identifier_lb_a_id = "${module.module_vpc.subnet_identifier_lb_a_id}"
  subnet_identifier_lb_c_id = "${module.module_vpc.subnet_identifier_lb_c_id}"
  vpc_identifier_id = "${module.module_vpc.vpc_identifier_id}"
  source = "../modules/alb"
}

module "module_autoscaling" {
  vpc_identifier_id = "${module.module_vpc.vpc_identifier_id}"
  subnet_identifier_ap_a_id = "${module.module_vpc.subnet_identifier_ap_a_id}"
  subnet_identifier_ap_c_id = "${module.module_vpc.subnet_identifier_ap_c_id}"
  lb_tg_identifier_arn = "${module.module_alb.lb_tg_identifier_arn}"
  instance_profile_identifier_ap = "${var.instance_profile_identifier_ap}"
  ami_ower_account_id = "${var.ami_ower_account_id}"
  sns_topic_name = "${var.sns_topic_name}"
  instance_type = "${var.instance_type}"
  spot_price = "${var.spot_price}"
  ami_name = "${var.ami_name}"
  key_name = "${var.key_name}"
  source = "../modules/autoscaling"
}

