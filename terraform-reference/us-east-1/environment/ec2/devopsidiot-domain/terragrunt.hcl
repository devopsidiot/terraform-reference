locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags     = local.env_vars.locals.tags
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git?ref=v2.19.0"
}

dependency "vpc" {
  config_path = "../../vpc"
}
dependency "key_pair" {
  config_path = "../../key-pair"
}
dependency "security_group_vpn" {
  config_path = "../../security-group/vpn"
}
dependency "iam_role" {
  config_path = "../../iam/devopsidiot-domain" #FixMe
}

inputs = {
  name = "msk-client-tls-${local.env_vars.locals.env}"

  ## Amazon Linux 2
  ami            = "ami-0d5eff06f840b45e9" #FixMe
  instance_type  = "t3.micro"              #FixMe
  instance_count = 1

  vpc_security_group_ids = [
    dependency.vpc.outputs.default_security_group_id,
    dependency.security_group_vpn.outputs.security_group_id
  ]

  key_name             = dependency.key_pair.outputs.key_pair_key_name
  subnet_id            = dependency.vpc.outputs.private_subnets[0]
  iam_instance_profile = dependency.iam_role.outputs.iam_instance_profile_name

  user_data = file("${get_terragrunt_dir()}/user-data.sh")

  tags = local.tags
}
