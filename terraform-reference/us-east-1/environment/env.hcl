locals {
  external_deps = read_terragrunt_config(find_in_parent_folders("external_deps.hcl"))
  common_vars   = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars   = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  product_vars  = read_terragrunt_config(find_in_parent_folders("product.hcl"))

  tags = merge(
    local.external_deps.dependency.settings.outputs.tags,
    local.common_vars.locals.tags,
    local.account_vars.locals.tags,
    local.region_vars.locals.tags,
    local.product_vars.locals.tags,
    {
      Environment = local.env
    }
  )

  env                             = "<environment>"
  account_id                      = local.account_vars.locals.account_id
  account_name                    = local.account_vars.locals.account_name
  product_name                    = local.product_vars.locals.product_name
  enable_loadtesting              = false
  sso_administrator_role_arn      = local.account_vars.locals.sso_administrator_role_arn
  sso_administrator_role_arn_fqdn = local.account_vars.locals.sso_administrator_role_arn_fqdn
  sso_developer_role_arn          = local.account_vars.locals.sso_developer_role_arn

  zone_name = "<project>-<environment.<internal>.<domain>.com"

  ### VPC
  vpc_cfg = {
    public_subnet_tags = {
      "kubernetes.io/cluster/${local.product_name}-${local.env}"          = "shared"
      "kubernetes.io/cluster/${local.product_name}-cluster2-${local.env}" = "shared"
    }
    private_subnet_tags = {
      "kubernetes.io/cluster/${local.product_name}-${local.env}"          = "shared"
      "kubernetes.io/cluster/${local.product_name}-cluster2-${local.env}" = "shared"
    }
  }

  ### EKS
  eks_cfg = {
    default = {
      eks_name = "${local.product_name}-${local.env}"
      map_roles = [
        {
          # SSO Devops
          rolearn  = local.sso_administrator_role_arn
          username = "sso-admin:{{SessionName}}"
          groups   = ["system:masters"]
        },
        {
          # SSO Developers
          rolearn  = local.sso_developer_role_arn
          username = "sso-developer:{{SessionName}}"
          groups   = ["sso-developers"]
        }
      ]
      map_users = [
        {
          userarn  = "arn:aws:iam::${local.account_id}:user/devops_backup"
          username = "devops_backup"
          groups   = ["system:masters"]
        },
      ]
      node_groups_defaults = {
        ami_type  = "AL2_x86_64"
        disk_size = 50
      }
      node_groups = {
        default = {
          min_capacity     = local.enable_loadtesting ? 20 : 4
          max_capacity     = local.enable_loadtesting ? 24 : 10
          desired_capacity = 6
          instance_types   = ["c5.xlarge"]

          k8s_labels = {
            Environment = local.env
            Nodegroup   = "default"
          }
          additional_tags = merge({
            "k8s.io/cluster-autoscaler/enabled"               = "true"
            "k8s.io/cluster-autoscaler/${local.product_name}" = "owned"
          }, local.tags)
        }
      }
    }
  }
  ### RDS
  rds_cfg = {
    default = {
      cluster_parameters = [
        #{
        #  apply_method = "pending-reboot"
        #  name = "ssl"
        #  value = false
        #}
      ]
      db_parameters = [
        #{
        #  apply_method = "immediate"
        #  name = "enable_sort"
        #  value = false
        #}
      ]
      multi_az          = false
      apply_immediately = true
      # Create from snapshot (only has effect on initial resource creation)
      snapshot_identifier = ""
    }
  }
  ##
  ## Elasticsearch
  ##
  es_config = {
    default = {
      es_name    = "${local.product_name}-${local.env}"
      es_version = "7.9"

      node_to_node_encryption_enabled                = true
      snapshot_options_automated_snapshot_start_hour = 23

      cluster_config = {
        dedicated_master_enabled = true
        dedicated_master_type    = (local.enable_loadtesting) == true ? "m5.xlarge.elasticsearch" : "t3.medium.elasticsearch"
        es_instance_type         = (local.enable_loadtesting) == true ? "m5.xlarge.elasticsearch" : "t3.medium.elasticsearch"
        zone_awareness_enabled   = "true"
        instance_count           = 3
        availability_zone_count  = 3
      }

      ebs_options = {
        ebs_enabled = "true"
        volume_size = "25"
      }

      encrypt_at_rest = {
        enabled = true
      }

      log_publishing_options = {
        enabled  = true
        log_type = "INDEX_SLOW_LOGS"
      }
    }
  }
}