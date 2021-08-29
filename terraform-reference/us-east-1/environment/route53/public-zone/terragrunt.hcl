locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env              = local.environment_vars.locals.env
  zone_name        = local.environment_vars.locals.zone_name
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

terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//0.14/r53/public-zone"
}

inputs = {
  zone_name = local.zone_name
  tags      = local.tags
  records = {
    "internal-api" = merge(local.record_defaults, {
      prefix  = "internal-api"
      type    = "CNAME"
      ttl     = "60"
      records = [run_cmd("kubectl", "--kubeconfig=${dependency.eks.outputs.kubeconfig_file}", "get", "-n", "environment", "ingress", "--selector=app.kubernetes.io/name=internal-api", "-o", "jsonpath={.items[*].status.loadBalancer.ingress[0].hostname}")]
    })
  }
}
