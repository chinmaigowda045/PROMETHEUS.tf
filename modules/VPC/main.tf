resource "aws_vpc" "VPC" {
  cidr_block       = var.VPC_cidr_block
  instance_tenancy = "default"
  tags = {
    Name = "VPC"
  }
}
#--------------------------------------------------------------------------------------
#only public subnet
resource "aws_subnet" "Public_Subnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name = "Public_Subnet"
  }
}
#--------------------------------------------------------------------------------------
#igw for route table
resource "aws_internet_gateway" "Prometheus_igw" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "Prometheus_igw"
  }
}

#--------------------------------------------------------------------------------------
#routing table
resource "aws_route_table" "Prometheus_public_RT" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = var.route_table_cidr
    gateway_id = aws_internet_gateway.Prometheus_igw.id
  }
  tags = {
    Name = var.Prometheus_public_RT
  }
}

#--------------------------------------------------------------------------------------
#route table association with subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.Public_Subnet.id
  route_table_id = aws_route_table.Prometheus_public_RT.id
}