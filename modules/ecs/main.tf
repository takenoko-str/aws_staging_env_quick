resource "aws_ecs_cluster" "this" {
  name = "ecs"
}

resource "aws_ecs_service" "this" {
  name                = "ecs-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.this.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  network_configuration {
    subnets          = [var.subnet_a_id, var.subnet_c_id]
    security_groups  = [var.sg_default_id]
    assign_public_ip = true

  }
}

data "template_file" "container_definitions" {
  #template = file(var.container_definitions_path)
  template = jsonencode(yamldecode(file("container-definitions/cowsay.yaml")))

  vars = {
    registry_path     = var.registry_path
    image_name        = var.image_name
    cow_name          = var.cow_name
    cw_log_group_name = var.cw_log_group_name
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "ecs-task-definition"
  container_definitions    = data.template_file.container_definitions.rendered
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}