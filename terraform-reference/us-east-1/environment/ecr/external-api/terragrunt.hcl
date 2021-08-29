locals {
  env_vars            = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  coresvc_account_arn = "arn:aws:iam::<account number>:root"
  env                 = local.env_vars.locals.env
  tags                = local.env_vars.locals.tags
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:lgallard/terraform-aws-ecr?ref=0.3.2"
}

inputs = {
  name = "monet-api"
  policy = templatefile("${get_terragrunt_dir()}/policy.json.tpl", {
    #core services arn variable for GitLab runners
    coresvc_account_arn = local.coresvc_account_arn
  })
  tags = local.tags

}
