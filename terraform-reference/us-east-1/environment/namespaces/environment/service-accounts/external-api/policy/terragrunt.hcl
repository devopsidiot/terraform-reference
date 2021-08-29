locals {
  namespace_vars = read_terragrunt_config(find_in_parent_folders("namespace.hcl"))

  tags = merge(
    local.namespace_vars.locals.tags,
    local.additional_tags
  )

  additional_tags = {
    Description = "Primary policy associated with picasso-api deployment service account"
  }
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v4.1.0"
}

dependency "s3" {
  config_path = "../../../s3/terraform-reference-bucket"
}

inputs = {
  name        = "picasso-api-${local.namespace_vars.locals.namespace}"
  description = "Primary policy for picasso-api deployment service account"
  tags        = local.tags
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${dependency.s3_picasso_purpose.outputs.this_s3_bucket_arn}/*"
            ]
        }
    ]
}
EOF
}
