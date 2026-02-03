# S3 buckets for policy testing
# Policies: check-s3-versioning-enabled, check-server-side-encryption-enabled, disallow-public-read-and-write-acl

# ------------------------------------------------------------------------------
# Compliant bucket: versioning + server-side encryption + no public read/write ACL
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "compliant" {
  bucket = "policy-test-compliant-bucket-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "policy-test-compliant"
    Environment = "policy-test"
  }
}

# check-s3-versioning-enabled: versioning enabled
resource "aws_s3_bucket_versioning" "compliant" {
  bucket = aws_s3_bucket.compliant.id

  versioning_configuration {
    status = "Enabled"
  }
}

# check-server-side-encryption-enabled: server-side encryption enabled
resource "aws_s3_bucket_server_side_encryption_configuration" "compliant" {
  bucket = aws_s3_bucket.compliant.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# disallow-public-read-and-write-acl: block public access, private ACL
resource "aws_s3_bucket_public_access_block" "compliant" {
  bucket = aws_s3_bucket.compliant.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "compliant" {
  bucket = aws_s3_bucket.compliant.id

  acl = "private"
}

# ------------------------------------------------------------------------------
# Data source for account ID (used in bucket name for uniqueness)
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
