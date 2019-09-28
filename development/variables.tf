#VPC
variable "vpc_cidr_block" {}
variable "rtb_lb_cidr_block" {}
variable "rtb_ap_cidr_block" {}
variable "subnet_lb_a_cidr_block" {}
variable "subnet_lb_c_cidr_block" {}
variable "subnet_ap_a_cidr_block" {}
variable "subnet_ap_c_cidr_block" {}
variable "subnet_db_a_cidr_block" {}
variable "subnet_db_c_cidr_block" {}
#ALB
variable "acm_yourdomain" {}
#ASG
variable "instance_profile_ap" {}
variable "ami_ower_account_id" {}
variable "sns_topic_name" {}
variable "instance_type" {}
variable "ami_name" {}
variable "key_name" {}
variable "spot_price" {}
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}