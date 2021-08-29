locals {
  namespace_vars = read_terragrunt_config(find_in_parent_folders("namespace.hcl"))
  tags = merge(
    local.namespace_vars.locals.tags,
    local.additional_tags
  )
  env        = local.namespace_vars.locals.env_vars.locals.env
  account_id = local.namespace_vars.locals.account_vars.locals.account_id
  additional_tags = {
  }
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-dynamodb-table.git//?ref=v1.1.0"
}

inputs = {

  name     = "my-project"
  hash_key = "id"
  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = local.tags
}
