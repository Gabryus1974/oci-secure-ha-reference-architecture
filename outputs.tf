output "app1_private_ip" {
  value = data.oci_core_vnic.app1.private_ip_address
}

output "app2_private_ip" {
  value = data.oci_core_vnic.app2.private_ip_address
}

output "lb_private_ip" {
  value = oci_load_balancer_load_balancer.app.ip_address_details[0].ip_address
}

output "bastion_id" {
  value = oci_bastion_bastion.main.id
}