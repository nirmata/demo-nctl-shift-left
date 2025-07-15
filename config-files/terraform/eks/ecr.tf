# ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name = "cis-demo-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.eks.arn
  }
} 