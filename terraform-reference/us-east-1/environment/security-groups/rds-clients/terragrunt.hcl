locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags = merge(
    local.env_vars.locals.tags,
    local.additional_tags
  )
  env = local.env_vars.locals.env
  additional_tags = {
  }

}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-security-group.git//?ref=v4.0.0"
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  name        = "rds-clients-${local.env}"
  description = "Members of this group can communicate with RDS"
  vpc_id      = dependency.vpc.outputs.vpc_id
  tags        = local.tags

}
