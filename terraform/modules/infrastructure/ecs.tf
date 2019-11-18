data "aws_ecr_repository" "repo" {
  name = var.project
}

data "template_file" "task_app" {
  template = file("${path.module}/tasks/app_task_definition.json")

  vars = {
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    app_port       = var.app_port
    app_port       = var.app_port
    app_image      = "${data.aws_ecr_repository.repo.repository_url}:${var.tag}"
    pgsql_dsn      = "pgsql:host=${aws_db_instance.rds.address};dbname=${var.db_name}"
    pgsql_user     = var.db_user
    pgsql_pass     = var.db_pass
  }
}

data "template_file" "task_db" {
  template = "${file("${path.module}/tasks/db_prepare.json")}"

  vars = {
    app_image  = "${data.aws_ecr_repository.repo.repository_url}:${var.tag}"
    pgsql_dsn  = "pgsql:host=${aws_db_instance.rds.address};dbname=${var.db_name}"
    pgsql_user = var.db_user
    pgsql_pass = var.db_pass
  }
}

resource "aws_ecs_cluster" "main" {
  name = var.project
  tags = {
    Project = var.project
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "app"
  container_definitions    = data.template_file.task_app.rendered
  execution_role_arn       = aws_iam_role.ecs.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  tags = {
    Project = var.project
  }
}

resource "aws_ecs_task_definition" "db" {
  family                   = "db"
  container_definitions    = data.template_file.task_db.rendered
  execution_role_arn       = aws_iam_role.ecs.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
}

resource "aws_ecs_service" "app" {
  name            = "${var.project}-app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private[*].id
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "app"
    container_port   = var.app_port
  }
  depends_on = ["aws_alb_listener.front_end", "aws_ecs_service.db"]
}

resource "aws_ecs_service" "db" {
  name            = "${var.project}-db"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.db.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = aws_subnet.private[*].id
  }
  depends_on = ["aws_alb_listener.front_end"]
}
