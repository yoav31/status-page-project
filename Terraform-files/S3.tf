
resource "random_id" "bucket_id" {
  byte_length = 4
}

# S3 Bucket
resource "aws_s3_bucket" "project_bucket" {
  bucket = "yoav-project-s3-${random_id.bucket_id.hex}"

  tags = {
    Name = "yoav-project-s3"
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.project_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.project_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.project_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket Policy - Public Read
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.project_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.project_bucket.arn}/*"
      }
    ]
  })
}

# CORS
resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.project_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}