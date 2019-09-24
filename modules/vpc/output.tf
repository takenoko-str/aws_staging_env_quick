output "vpc_identifier_id" {
    value = aws_vpc.vpc-identifier.id
}

output "subnet_identifier_lb_a_id" {
    value = aws_subnet.subnet-identifier-lb-a.id
}

output "subnet_identifier_lb_c_id" {
    value = aws_subnet.subnet-identifier-lb-c.id
}

output "subnet_identifier_ap_a_id" {
    value = aws_subnet.subnet-identifier-ap-a.id
}

output "subnet_identifier_ap_c_id" {
    value = aws_subnet.subnet-identifier-ap-c.id
}

output "subnet_identifier_db_a_id" {
    value = aws_subnet.subnet-identifier-db-a.id
}

output "subnet_identifier_db_c_id" {
    value = aws_subnet.subnet-identifier-db-c.id
}