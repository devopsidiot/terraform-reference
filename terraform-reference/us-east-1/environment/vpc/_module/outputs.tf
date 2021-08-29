/*
  cidr                 = local.vpc_cfg.cidr
  azs                  = local.vpc_cfg.azs
  private_subnets      = local.vpc_cfg.private_subnets
  public_subnets       = local.vpc_cfg.public_subnets

*/
output "azs" {
  value = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
}
output "private_subnets" {
  value = [
    aws_subnet.private-1a.id,
    aws_subnet.private-1b.id,
    aws_subnet.private-1c.id
  ]
}
output "public_subnets" {
  value = [
    aws_subnet.public-1a.id,
    aws_subnet.public-1b.id,
    aws_subnet.public-1c.id
  ]
}
output "database_subnets" {
  value = []
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}
