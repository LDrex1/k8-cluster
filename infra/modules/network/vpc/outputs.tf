output "vpc_arn" {
  value = aws_vpc.k8_vpc.arn
}
output "vpc_id" {
  value = aws_vpc.k8_vpc.id
}

output "k8_subnet_id" {
  value = aws_subnet.k8_cluster.id
}


output "k8_master_sg_id" {
  description = "Security group for master node"
  value       = aws_security_group.k8_master_node.id

}
output "k8_worker_security_group_id" {
  description = "Security group for worker node"
  value       = aws_security_group.k8_worker_node.id
}
output "bastion_security_group_id" {
  description = "Security group for bastion host"
  value       = aws_security_group.bastion_web_app.id
}

output "bastion_subnet_id" {
  value = aws_subnet.bastion.id
}