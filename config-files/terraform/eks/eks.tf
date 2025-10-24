# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_encryption_config = {
    resources = ["secrets"]
    provider_key_arn = aws_kms_key.eks.arn
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
      subnet_ids     = module.vpc.private_subnets
      iam_role_arn   = aws_iam_role.eks_node_role.arn
    }
  }

  create_iam_role = false
  iam_role_arn    = aws_iam_role.eks_cluster_role.arn
} 
