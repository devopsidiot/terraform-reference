locals {
  namespace_vars = read_terragrunt_config(find_in_parent_folders("namespace.hcl"))

  tags = merge(
    local.namespace_vars.locals.tags,
    local.additional_tags
  )

  description = "Primary policy associated with cluster-autoscaler service account"

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
  name        = "cluster-autoscaler-${local.namespace_vars.locals.namespace}"
  description = local.description
  tags        = local.tags

  policy = templatefile("${get_terragrunt_dir()}/policy.json.tpl", {
    // No vars
  })
}
