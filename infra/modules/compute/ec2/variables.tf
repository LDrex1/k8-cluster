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