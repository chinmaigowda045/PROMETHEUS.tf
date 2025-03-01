module "VPC" {
  source = "./modules/VPC"
  VPC_cidr_block = var.root_VPC_cidr_block
  subnet_cidr_block = var.root_subnet_cidr_block
  route_table_cidr = var.root_route_table_cidr
  Prometheus_public_RT = var.root_Prometheus_public_RT
}
module "EC2" {
  source = "./modules/EC2"
  master_instance_type = var.root_master_instance_type
  Worker_instance_type = var.root_worker_instance_type
  rsa_pem_key_name = var.root_rsa_pem_key_name
  pem_file_download_path = var.root_pem_file_download_path
  security_group_name = var.root_security_group_name
  VPC_ID = module.VPC.VPC_ID
  Public_Subnet_id = module.VPC.Public_Subnet_id
}

resource "null_resource" "remote-exec-Master" {
  depends_on = [module.EC2]
  connection {
    type = "ssh"  #for ssh
    user = var.user_name  #for user@ip
    agent = false      # whenever we do ssh from local it will ask to save the user so to avoid that agent is false
    host = module.EC2.master_instance_public_ips[0]   #  to get the first instance in the list
    private_key = file(var.root_pem_file_download_path)   #to load the content of private pem key file to this private key argument file(path) is used
  }
  provisioner "remote-exec" {
        inline = [
          # Update and install required packages
           "sudo apt-get update -y",
           "sudo apt-get install -y wget curl",
        
           # Install Node Exporter
           "wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz",
           "tar -xvzf node_exporter-1.3.1.linux-amd64.tar.gz",
           "sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/",
      
           # Create a systemd service for Node Exporter
           "echo '[Unit]\nDescription=Prometheus Node Exporter\nAfter=network.target\n\n[Service]\nUser=nobody\nExecStart=/usr/local/bin/node_exporter\nRestart=always\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/node_exporter.service",
           "sudo systemctl daemon-reload",
           "sudo systemctl enable node_exporter",
           "sudo systemctl start node_exporter",

           # Install Prometheus
           "wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz",
           "tar -xvzf prometheus-2.35.0.linux-amd64.tar.gz",
           "sudo mv prometheus-2.35.0.linux-amd64/prometheus /usr/local/bin/",
           "sudo mv prometheus-2.35.0.linux-amd64/promtool /usr/local/bin/",
      
           # Create a Prometheus configuration file to scrape Node Exporter
           "echo 'global:\n  scrape_interval: 15s\nscrape_configs:\n  - job_name: \"node_exporter\"\n    static_configs:\n      - targets: [\"localhost:9100\"]' | sudo tee /etc/prometheus/prometheus.yml",
      
           # Create a systemd service for Prometheus
           "echo '[Unit]\nDescription=Prometheus\nAfter=network.target\n\n[Service]\nExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --web.listen-address=0.0.0.0:9090\nRestart=always\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/prometheus.service",
           "sudo systemctl daemon-reload",
           "sudo systemctl enable prometheus",
           "sudo systemctl start prometheus",
        ]
    }
}
resource "null_resource" "remote-exec-Workers" {
  count = 2    #same as in ec2 module
  depends_on = [module.EC2]
  connection {
    type = "ssh"  #for ssh
    user = var.user_name  #for user@ip
    agent = false      # whenever we do ssh from local it will ask to save the user so to avoid that agent is false
    host = element(module.EC2.workers_instance_public_ips, count.index)  #to get the public ip
    private_key = file(var.root_pem_file_download_path)   #to load the content of private pem key file to this private key argument file(path) is used
  }
  provisioner "remote-exec" {
        inline = [
          # Update and install required packages
           "sudo apt-get update -y",
           "sudo apt-get install -y wget curl",
        
           # Install Node Exporter
           "wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz",
           "tar -xvzf node_exporter-1.3.1.linux-amd64.tar.gz",
           "sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/",
      
           # Create a systemd service for Node Exporter
           "echo '[Unit]\nDescription=Prometheus Node Exporter\nAfter=network.target\n\n[Service]\nUser=nobody\nExecStart=/usr/local/bin/node_exporter\nRestart=always\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/node_exporter.service",
           "sudo systemctl daemon-reload",
           "sudo systemctl enable node_exporter",
           "sudo systemctl start node_exporter",

           # Install Prometheus
           "wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz",
           "tar -xvzf prometheus-2.35.0.linux-amd64.tar.gz",
           "sudo mv prometheus-2.35.0.linux-amd64/prometheus /usr/local/bin/",
           "sudo mv prometheus-2.35.0.linux-amd64/promtool /usr/local/bin/",
      
           # Create a Prometheus configuration file to scrape Node Exporter
           "echo 'global:\n  scrape_interval: 15s\nscrape_configs:\n  - job_name: \"node_exporter\"\n    static_configs:\n      - targets: [\"localhost:9100\"]' | sudo tee /etc/prometheus/prometheus.yml",
      
           # Create a systemd service for Prometheus
           "echo '[Unit]\nDescription=Prometheus\nAfter=network.target\n\n[Service]\nExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --web.listen-address=0.0.0.0:9090\nRestart=always\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/prometheus.service",
           "sudo systemctl daemon-reload",
           "sudo systemctl enable prometheus",
           "sudo systemctl start prometheus",
        ]
    }
}