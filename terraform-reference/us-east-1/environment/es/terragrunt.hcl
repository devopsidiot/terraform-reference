locals {
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env          = local.env_vars.locals.env
  product_name = local.env_vars.locals.product_vars.locals.product_name
  region       = local.env_vars.locals.region_vars.locals.aws_region
  account_id   = local.env_vars.locals.account_vars.locals.account_id

  es_config_defaults = local.env_vars.locals.es_config.default

  tags = local.env_vars.locals.tags
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:lgallard/terraform-aws-elasticsearch.git//?ref=0.11.0"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  domain_name = "${local.env_vars.locals.domain_name}"

  elasticsearch_version                          = local.es_config_defaults.es_version
  cluster_config                                 = local.es_config_defaults.cluster_config
  ebs_options                                    = local.es_config_defaults.ebs_options
  encrypt_at_rest                                = local.es_config_defaults.encrypt_at_rest
  log_publishing_options                         = local.es_config_defaults.log_publishing_options
  snapshot_options_automated_snapshot_start_hour = local.es_config_defaults.snapshot_options_automated_snapshot_start_hour
  node_to_node_encryption_enabled                = local.es_config_defaults.node_to_node_encryption_enabled

  vpc_options = {
    subnet_ids         = slice(dependency.vpc.outputs.private_subnets, 0, length(dependency.vpc.outputs.availability_zones))
    security_group_ids = [dependency.eks.outputs.cluster_primary_security_group_id]
  }

  access_policies = templatefile("${get_terragrunt_dir()}/policy.json.tpl", {
    region      = local.region
    account_id  = local.account_id
    domain_name = local.env_vars.locals.domain_name
  })

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  tags = local.tags
}
