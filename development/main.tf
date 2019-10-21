terraform {
  backend "s3" {
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id = var.peer_vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  rtb_lb_cidr_block = var.rtb_lb_cidr_block
  rtb_ap_cidr_block = var.rtb_ap_cidr_block
  subnet_lb_a_cidr_block = var.subnet_lb_a_cidr_block
  subnet_lb_c_cidr_block = var.subnet_lb_c_cidr_block
  subnet_ap_a_cidr_block = var.subnet_ap_a_cidr_block
  subnet_ap_c_cidr_block = var.subnet_ap_c_cidr_block
  subnet_db_a_cidr_block = var.subnet_db_a_cidr_block
  subnet_db_c_cidr_block = var.subnet_db_c_cidr_block
  source = "../modules/vpc"
}

module "alb" {
  acm_yourdomain = var.acm_yourdomain
  subnet_lb_a_id = module.vpc.subnet_lb_a_id
  subnet_lb_c_id = module.vpc.subnet_lb_c_id
  vpc_id = module.vpc.vpc_id
  source = "../modules/alb"
}

module "autoscaling" {
  vpc_id = module.vpc.vpc_id
  subnet_ap_a_id = module.vpc.subnet_ap_a_id
  subnet_ap_c_id = module.vpc.subnet_ap_c_id
  lb_tg_arn = module.alb.lb_tg_arn
  instance_profile_ap = var.instance_profile_ap
  ami_ower_account_id = var.ami_ower_account_id
  sns_topic_name = var.sns_topic_name
  instance_type = var.instance_type
  spot_price = var.spot_price
  ami_name = var.ami_name
  key_name = var.key_name
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity

  source = "../modules/autoscaling"
}

module "ec2" {
  vpc_id = module.vpc.vpc_id
  subnet_lb_a_id = module.vpc.subnet_lb_a_id
  subnet_lb_c_id = module.vpc.subnet_lb_c_id
  ami_ower_account_id = var.ami_ower_account_id
  instance_type = var.instance_type
  ami_name = var.ami_name
  key_name = var.key_name
  recurrence_stop = var.recurrence_stop
  recurrence_start = var.recurrence_start
  source = "../modules/ec2"
}
