
resource "aws_network_interface" "k8_eni" {
  count     = 2
  subnet_id = var.k8_subnet_id

  tags = {
    Name = "Primary_ni_k8${count.index}"
  }
}
resource "aws_network_interface" "k8_bastion" {
  subnet_id = var.bastion_subnet_id

  tags = {
    Name = "Primary_ni_k8"
  }
}

resource "aws_instance" "k8_instances" {
  count = 2

  ami           = "ami-01ec84b284795cbc7"
  instance_type = var.instance_type

  network_interface {
    network_interface_id = element(aws_network_interface.k8_eni.*.id, count.index)
    device_index         = 0
  }
  tags = {
    Name : "${count.index == 0 ? "Master" : "Worker"}_node"
  }
}

resource "aws_instance" "bastion_instance" {
  # t2 micro ubuntu ami
  ami           = "ami-01ec84b284795cbc7"
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.k8_bastion.id
    device_index         = 0
  }

  tags = {
    Name : "Bastion_host_for_webapp"
  }
}