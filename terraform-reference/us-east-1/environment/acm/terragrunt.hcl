locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env              = local.environment_vars.locals.env
  zone_name        = local.environment_vars.locals.zone_name
  last_modified_by = get_env("TF_VAR_last_modified_by", "")
  common_vars      = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  record_defaults  = local.common_vars.locals.record_defaults
  common_tags      = local.common_vars.locals.tags
  tags = merge(local.common_tags, {
    Environment = local.env
  })
}

include {
  path = find_in_parent_folders()
}

dependency "zone" {
  config_path = "../route53"
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-acm.git?ref=v3.0.0"
}

inputs = {
  domain_name = local.zone_name
  zone_id     = dependency.zone.outputs.id
  subject_alternative_names = [ ## Example for your root hosted zone: "*.domain_name"
    "*.${local.zone_name}",     #FixMeLater
  ]
  validate_certificate = true
  validation_method    = "DNS"
  wait_for_validation  = false

  tags = local.tags
}
