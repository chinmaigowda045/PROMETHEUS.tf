output "master_instance_public_ips" {
  value = [for instance in aws_instance.Master : instance.public_ip]
}

output "workers_instance_public_ips" {
  value = [for instance in aws_instance.Workers : instance.public_ip]
}
