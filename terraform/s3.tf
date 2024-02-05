resource "aws_s3_bucket" "backup_bucket" {
  bucket = var.s3-bucket
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }

    abort_incomplete_multipart_upload_days = 7
  }
}
