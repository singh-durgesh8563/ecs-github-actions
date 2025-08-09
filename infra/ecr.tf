resource "aws_ecr_repository" "app" {
  name = "ecs-app"
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "ecs-app" }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
