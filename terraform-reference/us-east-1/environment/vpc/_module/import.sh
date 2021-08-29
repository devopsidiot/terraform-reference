#!/bin/bash

terragrunt import aws_vpc.vpc vpc- #FixMeLater
terragrunt import aws_subnet.private-1a subnet- #FixMeLater
terragrunt import aws_subnet.private-1b subnet- #FixMeLater
terragrunt import aws_subnet.private-1c subnet- #FixMeLater
terragrunt import aws_subnet.public-1a subnet- #FixMeLater
terragrunt import aws_subnet.public-1b subnet- #FixMeLater
terragrunt import aws_subnet.public-1c subnet- #FixMeLater