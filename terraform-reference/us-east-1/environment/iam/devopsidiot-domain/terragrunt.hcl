locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  ## @TODO make these dynamic
  cluster_account_id            = "" #FixMe
  cluster_account_iam_role_name = "" #FixMe
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v4.1.0"
}

inputs = {
  name        = "Project-${local.cluster_account_iam_role_name}"
  description = "My Project permissions." #FixMe

  policy = templatefile("${get_terragrunt_dir()}/policy.json.tpl", {
    account_id    = local.cluster_account_id
    iam_role_name = local.cluster_account_iam_role_name
  })
}
