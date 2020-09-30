resource "aws_ecr_repository" "service" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"
  tags                 = {}

  image_scanning_configuration {
    scan_on_push = false
  }
}