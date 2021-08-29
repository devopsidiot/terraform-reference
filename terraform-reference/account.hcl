locals {
  account_name = "devopsidiot-account" #FixMeFirst
  account_id   = "123456789098765"     #FixMeFirst
  #This style ARN is required for KMS IAM policy and most other AWS resources (except EKS)
  sso_administrator_role_arn_fqdn = "arn:aws:iam::${local.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_randomnumbers" #FixMeLater
  #This style ARN is required for EKS.
  sso_administrator_role_arn = "arn:aws:iam::${local.account_id}:role/AWSReservedSSO_AWSAdministratorAccess_randomnumbers"                            #FixMeLater
  sso_developer_role_arn     = "arn:aws:iam::${local.account_id}:role/AWSReservedSSO_Developer_randomnumbers"                                         #FixMeLater
  sso_power_user_role_arn    = "arn:aws:iam::${local.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSPowerUserAccess_randomnumbers" #FixMeLater
  tf_state_bucket_name       = "devopsidiot-tfstate-${local.account_name}"                                                                            #FixMeFirst
  tf_state_key_prefix        = "tf-state-${local.account_name}"
  tf_state_lock_table_name   = "tf-state-${local.account_name}-locks"

  tags = {
  }

}
