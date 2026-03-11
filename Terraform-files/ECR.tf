resource "aws_ecr_repository" "statuspage_repo" {
  name                 = "yoav-statuspage"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "yoav-statuspage-repo"
  }
}