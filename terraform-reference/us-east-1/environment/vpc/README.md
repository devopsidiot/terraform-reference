# Importing the VPC

This page covers how to build up a terragrunt VPC specification starting from an import of the VPC created by Control Tower. You will need to do this before creating any resources that are dependent on the VPC.

* Start with placeholder module for the VPC by creating a temporary file in `_module/main.tf` that contains the following:

```
    resource "aws_vpc" "vpc" {
    }
    resource "aws_subnet" "private-1a" {
    }
    resource "aws_subnet" "private-1b" {
    }
    resource "aws_subnet" "private-1c" {
    }
    resource "aws_subnet" "public-1a" {
    }
    resource "aws_subnet" "public-1b" {
    }
    resource "aws_subnet" "public-1c" {
    }
```
* Temporarily change the terraform `source` block in `terragrunt.hcl` to point to this local file:

    terraform {
        source = "_module"
    }

* Make sure the `input` block in this `terragrunt.hcl` is empty.

* Make sure variables.tf in ../_module is empty.

* Next, create an import script similar to `import.sh`. You'll need to look in the AWS console to find the ids of the VPC and subnets to add to the script. Once you have them identifed, add them into the script and run the import to capture the VPC to terragrunt state. <u>Run the following command from the root of the vpc folder.</u>

    ❯ ./_import/import.sh

After the initial import, change the teraform source point to `terraform-modules`:

    terraform {
        source = "source = "git@github.com:devopsidiot/terraform-modules.git//0.14/vpc-control-tower"
    }

* Here `${HASH_OR_TAG}` is either a git SHA or tag name in the `terraform-modules` repo.

* Make use of `terragrunt show` to find the details necessary to add to the `inputs` block in `terragrunt.hcl` such that you get a clean plan. You can paste this code block to replace your inputs and update the values before you try to run a plan.

```
inputs = {

  ##
  ## Static config from VPC created by Control Tower.
  ##

  vpc_id   = "vpc-1235464789"
  vpc_cidr = "10.140.64.0/18"

  subnet_cidr_blocks_private = {
    "1a" = "10.140.64.0/20"
    "1b" = "10.140.80.0/20"
    "1c" = "10.140.96.0/20"
  }

  subnet_cidr_blocks_public = {
    "1a" = "10.140.112.0/24"
    "1b" = "10.140.113.0/24"
    "1c" = "10.140.114.0/24"
  }

  ##
  ## Extending the control tower VPC.
  ##

  enable_dns_hostnames = true
  // enable_s3_endpoint = true

  public_subnet_tags = {
    Tier                                             = "public"
    // "kubernetes.io/role/elb"                      = 1
    // "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
  private_subnet_tags = {
    Tier                                             = "private"
    // "kubernetes.io/role/internal-elb"             = 1
    // "kubernetes.io/cluster/${local.cluster-name}" = "shared"
  }

  tags = merge(local.env_tags, local.import_tags)
}
```
* Now you may run `terragrunt plan`
* If the resulting plan ONLY adds tags and DOES NOT change any VPC related resources, then we have a clean plan and you can apply the changes.
* Once you have a clean plan, we can add customizations to the VPC config as usual per the normal terragrunt workflow. There are a few configuration items that should not be customized, covered below.

** The EKS cluster tags are commented out in this example. You will want to come back and uncomment them, run `terragrunt apply` once you have deployed the cluster.

## Prevent Control Tower Drift

~~Do not add custom tags to the VPC, as it will trigger drift in Control Tower.~~

We still don't have a solution for VPC tags in a way that Control Tower config isn't in a drifted state after we add the k8s-required tags to the VPC.
