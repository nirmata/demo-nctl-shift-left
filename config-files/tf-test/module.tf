module "thanos_s32" {
  source   = "app.terraform.io/our/custom/s3/module"
  version  = "0.0.1"
  for_each = toset(local.workspace["s3_thanos_config"])

  env                       = var.env
  region                    = var.region
  bucket_name               = "${each.key}-thanos"
  enable_lifecycle          = true
  kms_key_id                = module.kms_thanos.key_arn
  bucket_versioning_enabled = true
  readwrite_iam_role_arns = [
    "arn:${data.aws_partition.current.id}:iam::${var.aws_account}:root",
  ]

  additional_s3_bucket_policy_jsons = [
    data.aws_iam_policy_document.thanos_s3_additional_policy[each.key].json
  ]

  tags = merge(
    module.toolchain-tags.tags,
    {
      Name    = "${each.key}-thanos-${var.env}"
      Purpose = "thanos Object store"
    }
  )
}