resource "aws_s3_bucket" "terraform_backend_bucket" {
  bucket = "self-hosted-terraform-backend"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_backend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
