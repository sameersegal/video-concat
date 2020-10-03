resource "aws_ecr_repository" "repo" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"
  tags                 = {}

  image_scanning_configuration {
    scan_on_push = false
  }
}

output "docker_image_repo_url" {
  value = aws_ecr_repository.repo.repository_url
}