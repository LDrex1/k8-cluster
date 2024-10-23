variable "instance_type" {
  description = "instance type for resources"
  type        = string
  default     = "t2.micro"
}

variable "k8_subnet_id" {
  description = "Subnet ID for k8 cluster"
  type        = string
}
variable "bastion_subnet_id" {
  description = "Subnet ID for bastion host"
  type        = string
}

variable "k8_master_sg_id" {
  description = "Security group for master node"
  type        = string

}
variable "k8_worker_security_group_id" {
  description = "Security group for worker node"
  type        = string
}
variable "bastion_security_group_id" {
  description = "Security group for bastion host"
  type        = string
}

