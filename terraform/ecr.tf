resource "aws_ecr_repository" "todoapp" {
  name         = "${var.project_name}-todoapp"
  force_delete = true
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}