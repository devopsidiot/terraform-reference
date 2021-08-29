locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags = merge(
    local.env_vars.locals.tags,
    local.additional_tags
  )
  env                = local.env_vars.locals.env
  enable_loadtesting = local.env_vars.locals.enable_loadtesting
  db_creds           = yamldecode(sops_decrypt_file("${get_terragrunt_dir()}/db-creds.sops.yaml"))
  username           = local.db_creds.username
  password           = local.db_creds.password
  rds_cfg            = local.env_vars.locals.rds_cfg.default

  # Customize if needed
  additional_tags = {}

}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//0.14/rds"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "sg_rds_clients" {
  config_path = "../security-groups/rds-clients"
}

dependencies {
  paths = ["../kms/devops"]
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  username                = local.db_creds.username
  password                = local.db_creds.password
  name                    = "${local.env_vars.locals.product_name}-${local.env}"
  vpc_id                  = dependency.vpc.outputs.vpc_id
  subnets                 = length(dependency.vpc.outputs.database_subnets) > 0 ? dependency.vpc.outputs.database_subnets : dependency.vpc.outputs.private_subnets
  allowed_security_groups = [dependency.sg_rds_clients.outputs.this_security_group_id, dependency.eks.outputs.cluster_primary_security_group_id]
  allowed_cidr_blocks     = local.env_vars.locals.external-deps.dependency.settings.outputs.vpn_cidrs
  replica_count           = local.rds_cfg.replica_count
  apply_immediately       = local.rds_cfg.apply_immediately
  cluster_parameters      = local.rds_cfg.cluster_parameters
  db_parameters           = local.rds_cfg.db_parameters
  engine_version          = "12.4"
  family                  = "aurora-postgresql12" # DB parameter group
  instance_type           = "db.t3.medium"
  allocated_storage       = 40
  storage_type            = "gp2"
  replica_count           = 1
  tags                    = local.tags

  # Create from snapshot (only has effect on initial resource creation)
  snapshot_identifier = local.rds_cfg.snapshot_identifier

}
