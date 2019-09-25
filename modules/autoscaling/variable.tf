variable "vpc_identifier_id" {}
variable "subnet_identifier_ap_a_id" {}
variable "subnet_identifier_ap_c_id" {}
variable "instance_profile_identifier_ap" {}
variable "ami_ower_account_id" {}
variable "lb_tg_identifier_arn" {}
variable "sns_topic_name" {}
variable "instance_type" {}
variable "spot_price" {}
variable "ami_name" {}
variable "key_name" {}
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}
variable "cpu_utilization" {
  default = 40.0
}
variable "estimated_warmup_time" {
  default = "400"
}
variable "health_check_period" {
  default = "360"
}
