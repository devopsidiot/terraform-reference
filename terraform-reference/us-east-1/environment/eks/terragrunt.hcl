locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags = merge(
    local.env_vars.locals.tags,
    local.additional_tags
  )
  env        = local.env_vars.locals.env
  account_id = local.env_vars.locals.account_vars.locals.account_id
  eks_cfg    = local.env_vars.locals.eks_cfg.default

  # Customize if needed
  additional_tags = {
  }
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//0.14/eks"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name                 = local.eks_cfg.eks_name
  vpc_id               = dependency.vpc.outputs.vpc_id
  subnet_ids           = slice(dependency.vpc.outputs.private_subnets, 0, length(dependency.vpc.outputs.availability_zones))
  tags                 = local.tags
  kubeconfig_file      = "${get_terragrunt_dir()}/kubeconfig"
  node_groups_defaults = local.eks_cfg.node_groups_defaults
  node_groups          = local.eks_cfg.node_groups
  map_roles            = local.eks_cfg.map_roles
  map_users            = local.eks_cfg.map_users

  cluster_enabled_log_types             = ["controllerManager", "api", "audit"]
  cluster_log_retention_in_days         = "90"
  cluster_endpoint_private_access_cidrs = local.env_vars.locals.external-deps.dependency.settings.outputs.vpn_cidrs
  # This is temporary until VPN route is added by Tom
  cluster_endpoint_public_access = true
  wait_for_cluster_cmd           = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
  tags                           = local.tags
}
