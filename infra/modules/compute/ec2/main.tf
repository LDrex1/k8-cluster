
resource "aws_network_interface" "k8_eni" {
  count           = 2
  subnet_id       = var.k8_subnet_id
  security_groups = count.index == 0 ? [var.k8_master_sg_id] : [var.k8_worker_security_group_id]


  tags = {
    Name = "Primary_ni_k8${count.index}"
  }
}
resource "aws_network_interface" "k8_bastion" {
  subnet_id       = var.bastion_subnet_id
  security_groups = [var.bastion_security_group_id]
  tags = {
    Name = "Primary_ni_k8"
  }
}

resource "aws_instance" "k8_instances" {
  count = 2

#   ami           = "ami-01ec84b284795cbc7"
  ami           = "ami-0e8d228ad90af673b"
  instance_type = var.instance_type
  key_name      = "gen-k8-key-pair"

  network_interface {
    network_interface_id = element(aws_network_interface.k8_eni.*.id, count.index)

    device_index = 0
  }
  tags = {
    Name : "${count.index == 0 ? "Master" : "Worker"}_node"
  }
}

resource "aws_instance" "bastion_instance" {
  # t2 micro ubuntu ami
  ami           = "ami-0e8d228ad90af673b"
  instance_type = var.instance_type
  key_name      = "gen-k8-key-pair"


  network_interface {
    network_interface_id = aws_network_interface.k8_bastion.id
    device_index         = 0
  }

  tags = {
    Name : "Bastion_host_for_webapp"
  }
}

# resource "aws_ec2_instance_state" "stopped_state" {
#     for_each = {
#         bastion_instance = aws_instance.bastion_instance.id,
#         k8_instance = aws_instance.k8_instances[0].id,
#         k8_instance_1 = aws_instance.k8_instances[1].id
#     }
#   instance_id = each.value
#   state       = "stopped"
# }
resource "aws_ec2_instance_state" "running_state" {
  for_each = {
    bastion_instance = aws_instance.bastion_instance.id,
    k8_instance      = aws_instance.k8_instances[0].id,
    k8_instance_1    = aws_instance.k8_instances[1].id
  }
  instance_id = each.value
  state       = "running"
}