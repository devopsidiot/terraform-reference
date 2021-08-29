locals {
  namespace_vars = read_terragrunt_config(find_in_parent_folders("namespace.hcl"))

  tags = merge(
    local.namespace_vars.locals.tags,
    local.additional_tags
  )

  additional_tags = {
    Description = "Role to apply to ${local.name} EKS deployment service account"
  }

  # Name of role and service account (should be the same in EKS)
  name = "aws-load-balancer-controller"
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role-with-oidc?ref=v4.1.0"
}

dependency "eks" {
  config_path = "../../../../eks"
}

dependency "policy_primary" {
  config_path = "../policy"
}

inputs = {
  tags        = local.tags
  create_role = true

  role_name = "${local.name}-${local.namespace_vars.locals.namespace}"

  provider_urls = [dependency.eks.outputs.cluster_oidc_issuer_url]

  # Yes, the stupid var that follows this one is needed
  role_policy_arns = [
    dependency.policy_primary.outputs.arn
  ]
  number_of_role_policy_arns = 1

  # K8S namespace-scoped service account
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.namespace_vars.locals.namespace}:${local.name}"]
}
