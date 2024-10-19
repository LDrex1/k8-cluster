output "vpc_arn" {
  value = aws_vpc.k8_vpc.arn
}
output "vpc_id" {
  value = aws_vpc.k8_vpc.id
}

output "k8_subnet_id" {
  value = aws_subnet.k8_cluster.id
}


output "k8_security_group_ids" {
  description = "All security groups in the k8 cluster"

  value = [
    aws_security_group.k8_master_node.id,
    aws_security_group.k8_worker_node.id,
  ]
}
output "k8_master_security_group_id" {
  value = aws_security_group.k8_master_node
}

output "bastion_subnet_id" {
  value = aws_subnet.bastion.id
}