locals {
  external-deps = read_terragrunt_config(find_in_parent_folders("external-deps.hcl"))
  common_vars   = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars   = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  product_vars  = read_terragrunt_config(find_in_parent_folders("product.hcl"))
  env_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags = merge(
    local.env_vars.locals.tags,
    local.additional_tags
  )
  env = local.env_vars.locals.env
  additional_tags = {
  }
  account_id = local.account_vars.locals.account_id
  token      = local.account_vars.locals.pagerduty_api_token.key

}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "_module"
}

inputs = {
  account_id = local.account_id
  token      = local.token
}

