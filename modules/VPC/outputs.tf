# to pass this Public subnet to EC2 output is necessary
output "Public_Subnet_id" {
  value = aws_subnet.Public_Subnet.id
}