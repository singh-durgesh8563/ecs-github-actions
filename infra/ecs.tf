resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

locals {
  image_uri = "${aws_ecr_repository.app.repository_url}:latest"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/ecs-app"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "app" {
  family                   = "ecs-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_exec_role.arn

  container_definitions = jsonencode([
    {
      name         = "app"
      image        = local.image_uri
      essential    = true
      portMappings = [{ containerPort = 80, hostPort = 80, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/ecs-app"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "ecs-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
