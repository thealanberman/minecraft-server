resource "aws_s3_bucket" "mcserver" {
  bucket_prefix = var.bucket_prefix
  acl           = "private"

  versioning {
    enabled = var.versioning
  }

  lifecycle_rule {
    prefix  = var.bucket_key
    enabled = true

    noncurrent_version_expiration {
      days = var.noncurrent_version_expiration
    }
  }

  tags = {
    Name    = var.bucket_prefix
    purpose = "minecraft server backups"
  }
}
