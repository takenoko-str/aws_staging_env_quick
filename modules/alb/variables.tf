variable "acm_yourdomain" {}
variable "subnet_lb_a_id" {}
variable "subnet_lb_c_id" {}
variable "vpc_id" {}
variable "health_check_path" {
  default = "/login"
}
variable "health_check_status_code" {
  default = "200"
}

