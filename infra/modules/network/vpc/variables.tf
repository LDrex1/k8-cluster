variable "k8_vpc_cidr" {
  type        = string
  description = "Default cidr range for created VPCs"
  default     = "10.0.0.0/16"
}

variable "k8_vpc_tags" {
  type = map(any)
  default = { name = "main-vpc",
    function = "k8-cluster"
  }
}
