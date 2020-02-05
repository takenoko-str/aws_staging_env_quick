# env variable
variable "registry_path" {
  default = "docker/whalesay:latest"
}

variable "image_name" {
  default = "cowsay"
}

variable "cow_name" {
  default = "cowcow"
}

variable "ecs_event_role" {}
variable "execution_role_arn" {}
variable "subnet_a_id" {}
variable "subnet_c_id" {}
variable "sg_default_id" {}
variable "container_definitions_path" {}
variable "cw_log_group_name" {}
variable "cw_log_retention_in_days" {}
