provider "ibm" {
  region           = var.region
  #ibmcloud_api_key = var.ibmcloud_api_key
  generation       = 2
  ibmcloud_timeout = var.ibmcloud_timeout
}

locals {
  BASENAME = "${var.prefix}vpc-pubpriv"

  user_data_frontend = <<EOF
#!/bin/bash
apt-get update
apt-get install -y nginx
echo "I am the frontend server" > /var/www/html/index.html
service nginx start
EOF

}

data "ibm_is_image" "os" {
  name = var.image_name
}

module "vpc_pub_priv" {
  source              = "../tfmodule"
  basename            = local.BASENAME
  vpc_name            = var.vpc_name
  resource_group_name = var.resource_group_name
  ssh_key_name        = var.ssh_key_name
  zone                = var.zone
  # backend_pgw         = var.backend_pgw
  profile             = var.profile
  ibm_is_image_id     = data.ibm_is_image.os.id
  maintenance         = var.maintenance
  frontend_user_data  = local.user_data_frontend
  # backend_user_data   = local.user_data_backend
}

locals {
  bastion_ip = module.vpc_pub_priv.bastion_floating_ip_address
}

output "BASTION_IP_ADDRESS" {
  value = local.bastion_ip
}

output "sshbastion" {
  value = "ssh root@${local.bastion_ip}"
}

output "sshfrontend" {
  value = "ssh -o ProxyJump=root@${local.bastion_ip} root@${module.vpc_pub_priv.frontend_network_interface_address}"
}


output "FRONT_NIC_IP" {
  value = module.vpc_pub_priv.frontend_network_interface_address
}

output "sshfrontend2" {
  value = "ssh -o ProxyJump=root@${local.bastion_ip} root@${module.vpc_pub_priv.frontend2_network_interface_address}"
}


output "FRONT2_NIC_IP" {
  value = module.vpc_pub_priv.frontend2_network_interface_address
}
