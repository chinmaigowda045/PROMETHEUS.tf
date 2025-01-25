# to specify the type of pem key
resource "tls_private_key" "rsa_pem_key_type" {
  algorithm = "RSA"
  rsa_bits = 4096
}
# to create the pem key
resource "aws_key_pair" "rsa_pem_key_create" {
  key_name = var.rsa_pem_key_name
  public_key = tls_private_key.rsa_pem_key_type.public_key_openssh
}
#to save downloaded pem file in a specific folder
resource "local_file" "pem_key_file_path" {
  content = tls_private_key.rsa_pem_key_type.private_key_openssh
  filename = var.pem_file_download_path
}

#--------------------------------------------------------------------------------------
#to create a security group with ssh port 22 access
resource "aws_security_group" "SG_all_traffic" {
  name = var.security_group_name
}
resource "aws_vpc_security_group_ingress_rule" "SG_all_traffic_ingress" {
  security_group_id = aws_security_group.SG_all_traffic.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 0
  ip_protocol = "tcp"
  to_port = 65535
}
resource "aws_vpc_security_group_egress_rule" "SG_all_traffic_egress" {
  security_group_id = aws_security_group.SG_all_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#--------------------------------------------------------------------------------------
# for creation of ec2 instances using all above resources
resource "aws_instance" "Master" {
  count = 1
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = var.master_instance_type
  key_name = aws_key_pair.rsa_pem_key_create.key_name    # calling the created pem key
  subnet_id = var.Public_Subnet_id
  vpc_security_group_ids = [aws_security_group.SG_all_traffic.id]     # [] - #to mention the list of security groups if there are more than one
  associate_public_ip_address = true     # Automatically associate a public IP (if in a public subnet)
  tags = {
    Name = "Master-${count.index}"
  }
}
resource "aws_instance" "Workers" {
  count = 2
  ami           = "ami-04b4f1a9cf54c11d0" 
  instance_type = var.Worker_instance_type
  key_name = aws_key_pair.rsa_pem_key_create.key_name    # calling the created pem key
  subnet_id = var.Public_Subnet_id     # calling the subnet from other module, possible only after mentioning it in root module
  vpc_security_group_ids = [aws_security_group.SG_all_traffic.id]     # [] - #to mention the list of security groups if there are more than one
  associate_public_ip_address = true     # Automatically associate a public IP (if in a public subnet)
  tags = {
    Name = "Workers-${count.index}"
  }
}