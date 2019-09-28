output "lb_tg_arn" {
    value = aws_lb_target_group.this.arn
}

output "lb_arn" {
    value = aws_lb.this.arn
}
