![https://www.terraform.io/](https://img.shields.io/badge/terraform-v0.14.5-blue.svg?style=flat)
![https://www.terraform.io/](https://img.shields.io/badge/terragrunt-v0.29.0-yellow.svg?style=flat)
![](https://img.shields.io/maintenance/yes/2021.svg)
# tf-reference

## What This Repository Is For
This repository acts as a base example for creating infrastructure as code using Terraform & Terragrunt. This repository illustrates how to use namespaces to distinguish services from each other that support the same application. It also help distinguish between production and non-production namespaces.
<br>
<br>

## Terraform/Terragrunt Compatibility
You will need to use the version pinned at the repository root level for both Terraform and Terragrunt. Currently this repository is friendly to Terraform 0.14.x and Terragrunt 0.27.x
<br>
<br>

## Prerequisites
* The standard is to use the version of Terragrunt/Terraform that is pinned in the repository.
* Install tfenv to manage Terraform versions.
* Install tgenv to manage Terragrunt versions.
<br>
<br>

## General/Common Files (root level)
* common.hcl:
   * Repository URL
   * S3 bucket name
   * TF state file
   * TF state lock table
   * Base set of tags
   * Last modified by ${engineer} on last commit
* product.hcl
  * Product name for the service you are deploying
  * Application 
  * Team name   
  * Business Unit 
* terragrunt.hcl
  * Local paths for region, account, etc.
  * Provider blocks
  * TF state information
* Pinned Versions
  * Terraform
  * Terragrunt
<br>
<br>

## Patterns & Namespace Conventions
* Namespace hierarchy
  * Service
    * Unity
  * External dependencies/region
    * us-east-1
  * Environment
    * Dev
    * Stg
    * Preprod
  * Resource
    * S3
    * IAM Service Accounts

* Inside of the nonprod namespace are resources that are shared amongst dev, stg, preprod such as PagerDuty, EKS, KMS, VPC, and Security Groups. All other env specific resources belong in their respective namespace.

* Inside of each resource namespace is a Terragrunt file which includes:
    * Local paths
    * Include path for parent folders
    * Any additonal tags necessary
    * Inputs for modules & module references
    * Create resource or reference existing resources
<br>
<br>

## Secrets Management
* Currently uses SOPS to store and ecrypt secrets and comprises of
  * A simple .yaml file stores the plain text secret to encrypt
  * A script to encrypt that file
  * A script to decrypt that file
<br>
<br>

## Environmental Variables (env.hcl)
* Stores local paths
* Performs any tag merges
* Sets default inputs by environment for each resource
<br>
<br>

## Account Variables (account.hcl)
* Sets AWS account number
* Any IAM roles to be used
* Terraform state file information

## To-Do:
* Add a pattern to handle Lambda deploys
* <s>Add a pattern for PagerDuty/CloudWatch alarms</s>
* <s>Make repository compatible with Terraform =>0.14.0</s>

<br>

## Helpful URL's
https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/extension
