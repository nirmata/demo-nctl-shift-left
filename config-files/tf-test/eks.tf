# Converted from eks.json (Terraform plan JSON)
# terraform_version: 1.6.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "cluster_name" {
  type    = string
  default = "cis-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}

variable "domain_name" {
  type    = string
  default = "example.com"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Required for EKS module and ALB (subnet IDs from VPC)
variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS cluster and load balancer will be created"
  default     = "vpc-placeholder"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EKS cluster"
  default     = ["subnet-private1", "subnet-private2"]
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for ALB"
  default     = ["subnet-public1", "subnet-public2"]
}

# ------------------------------------------------------------------------------
# Root module resources (from planned_values.root_module.resources)
# ------------------------------------------------------------------------------

resource "aws_acm_certificate" "https_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [var.domain_name]
}

resource "aws_ecr_repository" "app_repo" {
  name = "cis-demo-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "cis-eks-cluster-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "eks_node_role" {
  name = "cis-eks-node-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS secret encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_lb" "app_alb" {
  name               = "cis-demo-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids

  enable_http2    = true
  idle_timeout    = 60
  desync_mitigation_mode = "defensive"
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.https_cert.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "cis-demo-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
  target_type = "instance"

  deregistration_delay = 300

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTPS"
  }
}

# ------------------------------------------------------------------------------
# EKS module (from planned_values.root_module.child_modules - module.eks)
# ------------------------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = aws_kms_key.eks.arn
  }

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      name            = "default"
      instance_types  = var.node_instance_types
      min_size        = var.node_min_size
      max_size        = var.node_max_size
      desired_size    = var.node_desired_size

      tags = {
        Name = "default"
      }
    }
  }

  tags = {
    "terraform-aws-modules" = "eks"
  }
}

# ------------------------------------------------------------------------------
# Outputs (from planned_values.outputs)
# ------------------------------------------------------------------------------

output "alb_dns_name" {
  value       = aws_lb.app_alb.dns_name
  description = "DNS name of the application load balancer"
}

output "ecr_repo_url" {
  value       = aws_ecr_repository.app_repo.repository_url
  description = "ECR repository URL"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster API endpoint"
}

output "private_subnet_ids" {
  value       = var.private_subnet_ids
  description = "Private subnet IDs"
}

output "public_subnet_ids" {
  value       = var.public_subnet_ids
  description = "Public subnet IDs"
}

output "vpc_id" {
  value       = var.vpc_id
  description = "VPC ID"
}
