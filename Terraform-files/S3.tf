resource "aws_s3_bucket" "project_bucket" {
  bucket = "yoav-project-s3" 

  tags = {
    Name = "yoav-project-s3"
  }
}
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.project_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}