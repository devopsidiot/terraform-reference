locals {
  namespace_vars = read_terragrunt_config(find_in_parent_folders("namespace.hcl"))

  tags = merge(
    local.namespace_vars.locals.tags,
    local.additional_tags
  )

  description = "Primary policy associated with aws-load-balancer-controller service account"

  additional_tags = {
    Description = local.description
  }
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v4.1.0"
}

inputs = {
  name        = "get-ecr-auth"
  description = "Allow attached entities, such as flux in eks, to obtain an ECR authorization token."
  policy = templatefile("${get_terragrunt_dir()}/policy.json.tpl", {
    // No vars
  })
}