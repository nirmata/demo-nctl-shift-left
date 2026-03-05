# ACM Certificate (for HTTPS ALB)
resource "aws_acm_certificate" "https_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = false
  }
} 
