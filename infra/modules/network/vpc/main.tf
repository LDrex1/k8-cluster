
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
resource "aws_vpc" "k8_vpc" {
  cidr_block = var.k8_vpc_cidr
  tags = {
    Name = "Ter-k8"
  }
}

# Internet gateway definition
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.k8_vpc.id

  tags = {
    Name   = "internet-gateway-for-k8-vpc"
    Source = "Terraform"
  }
}
resource "aws_eip" "k8_eip" {
  depends_on = [ aws_internet_gateway.gateway]
}
resource "aws_nat_gateway" "k8_nat_gateway" {
  subnet_id = aws_subnet.bastion.id
  allocation_id = aws_eip.k8_eip.id

  tags = {
    Name = "k8_nat_gateway"
    Source = "Terraform"
  }

  depends_on = [ aws_internet_gateway.gateway ]
}

# Route table

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.k8_vpc.id

  route {
    cidr_block       = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8_nat_gateway.id
      }

  tags = {
    Name   = "private-route-table"
    Source = "Terraform"
  }
}

resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.k8_cluster.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.k8_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id   = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "Public Route Table"
    Source = "Terraform"
  }
}


# resource "aws_route" "route" {
#   route_table_id         = aws_vpc.k8_vpc.main_route_table_id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.gateway.id


# }

resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.bastion.id
  route_table_id = aws_route_table.public_route_table.id
}

data "aws_availability_zones" "available" {}

# Subnet definition for master and worker nodes. 
resource "aws_subnet" "k8_cluster" {
  vpc_id                  = aws_vpc.k8_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, 0)

  tags = {
    Name   = "k8-nodes-subnet-${element(data.aws_availability_zones.available.names, 0)}"
    Source = "Terraform"

  }
}

# Subnet definition for baston host. 
resource "aws_subnet" "bastion" {
  vpc_id                  = aws_vpc.k8_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, 1)

  tags = {
    Name   = "bastion-host-subnet-${element(data.aws_availability_zones.available.names, 1)}"
    Source = "Terraform"

  }
}


resource "aws_security_group" "bastion_web_app" {
  name   = "bastion-web-app-sg"
  vpc_id = aws_vpc.k8_vpc.id



  tags = {
    Name   = "bastion_web_host"
    Source = "Terraform"

  }
}
resource "aws_security_group" "k8_master_node" {
  name   = "k8_master_sg"
  vpc_id = aws_vpc.k8_vpc.id



  tags = {
    Name   = "k8_master_sg"
    Source = "Terraform"

  }
}
resource "aws_security_group" "k8_worker_node" {
  name   = "k8_worker_sg"
  vpc_id = aws_vpc.k8_vpc.id



  tags = {
    Name   = "k8_worker_sg"
    Source = "Terraform"

  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {

  for_each = {
    k8_master_node          = aws_security_group.k8_master_node.id,
    k8_worker_node          = aws_security_group.k8_worker_node.id,
    Bastion_host_for_webapp = aws_security_group.bastion_web_app.id
  }
  depends_on = [aws_security_group.k8_master_node,
  aws_security_group.k8_worker_node, aws_security_group.bastion_web_app]

  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "TCP"
  to_port           = 22

  tags = { Name : "SSH rule" }

}
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
    for_each = {
    k8_master_node          = aws_security_group.k8_master_node.id,
    Bastion_host_for_webapp = aws_security_group.bastion_web_app.id
  }
  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "TCP"
  to_port           = 443
  depends_on = [aws_security_group.k8_master_node,
  aws_security_group.bastion_web_app, ]

  tags = { Name : "Https" }

}
resource "aws_vpc_security_group_ingress_rule" "allow_k8" {
  security_group_id = aws_security_group.k8_worker_node.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 30000
  ip_protocol       = "TCP"
  to_port           = 32677
  depends_on = [aws_security_group.k8_master_node,
  aws_security_group.k8_worker_node, ]
}
resource "aws_vpc_security_group_egress_rule" "allow_outbound_ssh" {
  security_group_id = aws_security_group.bastion_web_app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "TCP"
  to_port           = 22

  tags = { Name : "SSH rule" }
}
resource "aws_vpc_security_group_egress_rule" "allow_outbound_https" {
    for_each = {
    k8_master_node          = aws_security_group.k8_master_node.id,
    k8_worker_node          = aws_security_group.k8_worker_node.id,
    Bastion_host_for_webapp = aws_security_group.bastion_web_app.id
  }
  security_group_id = each.value
   cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "TCP"
  to_port           = 443

  tags = { Name : "https rule" }
}
resource "aws_vpc_security_group_egress_rule" "allow_outbound_http" {
    for_each = {
    k8_master_node          = aws_security_group.k8_master_node.id,
    k8_worker_node          = aws_security_group.k8_worker_node.id,
    Bastion_host_for_webapp = aws_security_group.bastion_web_app.id
  }
  security_group_id = each.value
   cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "TCP"
  to_port           = 80

  tags = { Name : "http rule" }
}

