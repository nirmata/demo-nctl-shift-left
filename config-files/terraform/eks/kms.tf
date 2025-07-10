# KMS key for secret encryption
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS secret encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
} 