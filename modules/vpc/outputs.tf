output "vpc_id" {
    value = aws_vpc.this.id
}

output "subnet_lb_a_id" {
    value = aws_subnet.lb_a.id
}

output "subnet_lb_c_id" {
    value = aws_subnet.lb_c.id
}

output "subnet_ap_a_id" {
    value = aws_subnet.ap_a.id
}

output "subnet_ap_c_id" {
    value = aws_subnet.ap_c.id
}

output "subnet_db_a_id" {
    value = aws_subnet.db_a.id
}

output "subnet_db_c_id" {
    value = aws_subnet.db_c.id
}