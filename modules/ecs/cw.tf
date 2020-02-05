resource "aws_cloudwatch_event_rule" "this" {
  name                = "cowsay"
  description         = "this is test"
  schedule_expression = "cron(*/3 * * * ? *)"
}

data "template_file" "container_overrides" {
  #template = file("./run_task.json")
  template = jsonencode(yamldecode(file("./run_task.yaml")))
}

resource "aws_cloudwatch_event_target" "this" {
  target_id = "cowsay"
  arn       = aws_ecs_cluster.this.arn
  rule      = aws_cloudwatch_event_rule.this.name
  role_arn  = var.ecs_event_role
  input     = data.template_file.container_overrides.rendered
  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.this.arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = [var.subnet_a_id, var.subnet_c_id]
      security_groups  = [var.sg_default_id]
      assign_public_ip = true
    }
  }
  lifecycle {
    ignore_changes = [ecs_target]
  }
}