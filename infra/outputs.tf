output "vpc_private_subnets" {
  value = module.vpc.vpc_arn
}

output "k8_security_group_ids" {
  value = module.vpc.k8_security_group_ids
}