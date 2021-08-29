locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags = merge(
    local.env_vars.locals.tags,
    local.additional_tags
  )
  env     = local.env_vars.locals.env
  vpc_cfg = local.env_vars.locals.vpc_cfg

  # Customize if needed
  additional_tags = {
    AWS_Solutions = "CustomControlTowerStackSet"
  }

}

include {
  path = find_in_parent_folders()
}

# This is a control tower default VPC so never delete it in TF
prevent_destroy = true
terraform {
  source = "_module"
  // source = "git@github.com:devopsidiot/terraform-modules.git//0.14/vpc-control-tower?ref=vpc-control-tower-0.14-0.1.0"
}

#Leave inputs empty so we can import the VPC from Control Tower.
inputs = {


}