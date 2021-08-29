locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_tags = local.env_vars.locals.tags
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-key-pair.git?ref=v1.0.0"
}

inputs = {
  ## public_key is set in environment, see README.md.
  key_name = "devops"
  tags     = local.env_tags
}
