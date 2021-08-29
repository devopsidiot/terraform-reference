locals {
  namespace_vars = read_terragrunt_config(find_in_parent_folders("namespace.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars       = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  namespace    = local.namespace_vars.locals.namespace
  account_name = local.namespace_vars.locals.account_vars.locals.account_name
  product_name = local.namespace_vars.locals.product_vars.locals.product_name
  bucket_key   = "purpose" #FixMeLater

  tags = merge(
    local.namespace_vars.locals.tags,
    {
      Description = "Bucket purpose or usage info." #FixMeLater
    }
  )
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v2.1.0"
}

inputs = {
  bucket        = "${local.product_name}-${local.bucket_key}-${local.namespace}"
  tags          = local.tags
  acl           = "private"
  attach_policy = true

  # EXAMPLE S3 Policy
  policy = jsonencode({
    "Id" : "EXAMPLEGlobalReadPolicy",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Allows Global Read",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.account_vars.locals.account_id}:root"
        },
        "Action" : "s3:GetObject",
        "Resource" : [
          "arn:aws:s3:::${local.product_name}-${local.bucket_key}-${local.namespace}",
          "arn:aws:s3:::${local.product_name}-${local.bucket_key}-${local.namespace}/*"
        ]
      }
    ]
  })
}
