
# Default ACL for the vpv
resource "aws_network_acl" "k8_vpc" {
  vpc_id = aws_vpc.k8_vpc.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# Vpc resource
resource "aws_vpc" "k8_vpc"{
    cidr_block = var.k8_vpc_cidr
    tags = {
    Name = "Ter-k8"
  }
}

# Internet gateway definition
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.k8_vpc.id

  tags = {
    Name = "internet-gateway-for-k8-vpc"
    Source = "Terraform"
  }
}

# Route table
resource "aws_route" "route" {
  route_table_id         = aws_vpc.k8_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id

  
}

data "aws_availability_zones" "available" {}

# Subnet definition for master and worker nodes. 
resource "aws_subnet" "k8_cluster" {
  count                   = 1
  vpc_id                  = aws_vpc.k8_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "k8-nodes-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
    Source = "Terraform"

  }
}

# Subnet definition for baston host. 
resource "aws_subnet" "bastion" {
  count                   = 1
  vpc_id                  = aws_vpc.k8_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, 1)

  tags = {
    Name = "bastion-host-subnet-${element(data.aws_availability_zones.available.names, 1)}"
    Source = "Terraform"

  }
}


resource "aws_security_group" "k8_master_node" {
  name = "k8_master_sg"
  vpc_id = aws_vpc.k8_vpc.id

  tags = {
    Name = "k8_master_sg"
    Source = "Terraform"

  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.k8_master_node.id
  cidr_ipv4         ="0.0.0.0/0"
  from_port         = 22
  ip_protocol       ="TCP"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.k8_master_node.id
  cidr_ipv4         ="0.0.0.0/0"
  from_port         = 443
  ip_protocol       ="TCP"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_k8" {
  security_group_id = aws_security_group.k8_master_node.id
  cidr_ipv4         ="0.0.0.0/0"
  from_port         = 30000
  ip_protocol       ="TCP"
  to_port           = 32677
}

