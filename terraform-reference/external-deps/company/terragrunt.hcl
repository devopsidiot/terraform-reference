locals {
  common_vars          = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  audacy_settings_repo = local.common_vars.locals.audacy_settings_repo
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = local.audacy_settings_repo
}