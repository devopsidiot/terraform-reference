locals {
  external-deps = read_terragrunt_config(find_in_parent_folders("external-deps.hcl"))
  common_vars   = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars   = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  product_vars  = read_terragrunt_config(find_in_parent_folders("product.hcl"))
  env_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  namespace = "environment" #FixMeFirst

  tags = merge(
    local.env_vars.locals.tags,
    {
      Namespace = local.namespace
    }
  )
}
