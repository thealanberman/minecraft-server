resource "aws_s3_bucket" "mcserver" {
  bucket_prefix = var.bucket
  acl           = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    prefix  = var.bucket_key
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }

  tags = {
    Name    = var.bucket
    purpose = "minecraft server backups"
  }
}
