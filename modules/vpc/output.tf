output "vpc-identifier-id" {
    value = aws_vpc.vpc-identifier.id
}

output "subnet-identifier-lb-a-id" {
    value = aws_subnet.subnet-identifier-lb-a.id
}

output "subnet-identifier-lb-c-id" {
    value = aws_subnet.subnet-identifier-lb-c.id
}

output "subnet-identifier-ap-a-id" {
    value = aws_subnet.subnet-identifier-ap-a.id
}

output "subnet-identifier-ap-c-id" {
    value = aws_subnet.subnet-identifier-ap-c.id
}

output "subnet-identifier-db-a-id" {
    value = aws_subnet.subnet-identifier-db-a.id
}

output "subnet-identifier-db-c-id" {
    value = aws_subnet.subnet-identifier-db-c.id
}