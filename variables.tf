variable "root_master_instance_type" {
  type = string
  default = "t2.medium"
}
variable "root_worker_instance_type" {
  type = string
  default = "t2.micro"
}
variable "root_rsa_pem_key_name" {
  type = string
  default = "Prometheus"
}
variable "root_pem_file_download_path" {
  type = string
  default = "./keys/Prometheus.pem"
}
variable "root_security_group_name" {
  type = string
  default = "SG_all_traffic"
}
variable "root_VPC_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}
variable "root_subnet_cidr_block" {
  type = string
  default = "10.0.0.0/24"
}
variable "root_route_table_cidr" {
  type = string
  default = "10.1.0.0/24"
}
variable "root_Prometheus_public_RT" {
  type = string
  default = "Prometheus_public_RT"
}

#-------------------------------------------------------------------------------------
variable "user_name" {
  type = string
  default = "root"
}