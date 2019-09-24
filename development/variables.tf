#VPC
variable "vpc_identifier_cidr_block" {}
variable "rtb_identifier_lb_cidr_block" {}
variable "rtb_identifier_ap_cidr_block" {}
variable "subnet_identifier_lb_a_cidr_block" {}
variable "subnet_identifier_lb_c_cidr_block" {}
variable "subnet_identifier_ap_a_cidr_block" {}
variable "subnet_identifier_ap_c_cidr_block" {}
variable "subnet_identifier_db_a_cidr_block" {}
variable "subnet_identifier_db_c_cidr_block" {}
#ALB
variable "acm_yourdomain" {}
#ASG
variable "instance_profile_identifier_ap" {}
variable "ami_ower_account_id" {}
variable "sns_topic_arn" {}
variable "instance_type" {}
variable "ami_name" {}
variable "key_name" {}