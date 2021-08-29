locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env              = local.environment_vars.locals.env
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

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//0.14/r53/private-zone"
}

inputs = {
  zone_name = "devopsidiot.com"
  tags      = local.tags
  vpc_id    = dependency.vpc.outputs.vpc_id
  records = {
    "internal-api.devopsidiot.com" = merge(local.record_defaults, {
      prefix  = "internal-api"
      type    = "CNAME"
      ttl     = "60"
      records = ["project-nlb-internal-45cf92cbc6788470.elb.us-east-1.amazonaws.com."]
    })
  }
}