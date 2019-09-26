variable "vpc_identifier_cidr_block" {
      default = "10.129.0.0/16"
}
variable "rtb_identifier_lb_cidr_block" {
      default = "0.0.0.0/0"
}
variable "rtb_identifier_ap_cidr_block" {
      default = "0.0.0.0/0"
}
variable "subnet_identifier_lb_a_cidr_block" {
      default = "10.129.0.0/24"
}
variable "subnet_identifier_lb_c_cidr_block" {
      default = "10.129.1.0/24"
}
variable "subnet_identifier_ap_a_cidr_block" {
      default = "10.129.16.0/24"
}
variable "subnet_identifier_ap_c_cidr_block" {
      default = "10.129.17.0/24"
}
variable "subnet_identifier_db_a_cidr_block" {
      default = "10.129.56.0/24"
}
variable "subnet_identifier_db_c_cidr_block" {
      default = "10.129.57.0/24"
}