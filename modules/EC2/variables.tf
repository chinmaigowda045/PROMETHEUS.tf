variable "master_instance_type" {
  type = string
  default = ""
}
variable "Worker_instance_type" {
  type = string
  default = ""
}
variable "rsa_pem_key_name" {
  type = string
  default = ""
}
variable "pem_file_download_path" {
  type = string
  default = ""
}
variable "security_group_name" {
  type = string
  default = ""
}
variable "Public_Subnet_id" {
  type = string
  default = ""
}