# CIS-compliant EKS Terraform configuration
# This configuration is now organized into separate files for better maintainability:
#
# - provider.tf     - Terraform and AWS provider configuration
# - variables.tf    - Variable definitions
# - vpc.tf         - VPC and networking resources
# - iam.tf         - IAM roles and policies
# - kms.tf         - KMS key for encryption
# - eks.tf         - EKS cluster configuration
# - ecr.tf         - ECR repository
# - acm.tf         - ACM certificate
# - alb.tf         - Application Load Balancer
# - outputs.tf     - Output values
#

