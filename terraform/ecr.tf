resource "aws_ecr_repository" "download" {
  name                 = "${var.ecr_name}-download"
  image_tag_mutability = "MUTABLE"
  tags                 = {}

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "convert" {
  name                 = "${var.ecr_name}-convert"
  image_tag_mutability = "MUTABLE"
  tags                 = {}

  image_scanning_configuration {
    scan_on_push = false
  }
}


output "download_image_repo_url" {
  value = aws_ecr_repository.download.repository_url
}

output "convert_image_repo_url" {
  value = aws_ecr_repository.convert.repository_url
}