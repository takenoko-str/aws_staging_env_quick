output "lb_tg_identifier_arn" {
    value = aws_lb_target_group.lb-tg-identifier.arn
}

output "lb_identifier_arn" {
    value = aws_lb.lb-identifier.arn
}
