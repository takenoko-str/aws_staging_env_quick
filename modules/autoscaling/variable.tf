variable "vpc_identifier_id" {}
variable "subnet_identifier_ap_a_id" {}
variable "subnet_identifier_ap_c_id" {}
variable "instance_profile_identifier_ap" {}
variable "ami_ower_account_id" {}
variable "lb_tg_identifier_arn" {}
variable "sns_topic_name" {}
variable "ami_name" {}
variable "key_name" {}
variable "spot_price" {
  default = "0.1"
}
variable "min_size" {
  default = 0
}
variable "max_size" {
  default = 6
}
variable "instance_type" {
  default = "m5.large"
}
variable "desired_capacity" {
  default = 1
}
variable "cpu_utilization" {
  default = 40.0
}
variable "default_cooldown_time" {
  default = "300"
}
variable "estimated_warmup_time" {
  default = "30"
}
variable "health_check_period" {
  default = "300"
}
variable "heartbeat_timeout" {
  default = "600"
}
