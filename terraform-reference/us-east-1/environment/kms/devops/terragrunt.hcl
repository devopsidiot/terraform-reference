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

}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//0.14/kms"
}

inputs = {
  alias               = "alias/devops-secrets"
  description         = "Used for managing devops-maintained encrypted data"
  enable_key_rotation = true
  tags                = local.tags
  sops_file           = "${get_terragrunt_dir()}/.sops.yaml"

  policy = templatefile("${get_terragrunt_dir()}/policy.json.tpl", {
    sso_administrator_role_arn_fqdn = local.env_vars.locals.sso_administrator_role_arn_fqdn
  })

}
