resource "oci_load_balancer_load_balancer" "app" {
  compartment_id = var.compartment_ocid
  display_name   = "tf-oci-refresh-app-lb"

  shape = "flexible"

  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }

  subnet_ids = [
    oci_core_subnet.private.id
  ]

  is_private = true

  network_security_group_ids = [
    oci_core_network_security_group.lb.id
  ]
}

resource "oci_load_balancer_backend_set" "app" {
  name             = "app-backend-set"
  load_balancer_id = oci_load_balancer_load_balancer.app.id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "HTTP"
    port              = 80
    url_path          = "/"
    return_code       = 200
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
  }
}

data "oci_core_vnic_attachments" "app1" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.app1.id
}

data "oci_core_vnic" "app1" {
  vnic_id = data.oci_core_vnic_attachments.app1.vnic_attachments[0].vnic_id
}

data "oci_core_vnic_attachments" "app2" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.app2.id
}

data "oci_core_vnic" "app2" {
  vnic_id = data.oci_core_vnic_attachments.app2.vnic_attachments[0].vnic_id
}

resource "oci_load_balancer_backend" "app1" {
  load_balancer_id = oci_load_balancer_load_balancer.app.id
  backendset_name  = oci_load_balancer_backend_set.app.name

  ip_address = data.oci_core_vnic.app1.private_ip_address
  port       = 80
  weight     = 1
}

resource "oci_load_balancer_backend" "app2" {
  load_balancer_id = oci_load_balancer_load_balancer.app.id
  backendset_name  = oci_load_balancer_backend_set.app.name

  ip_address = data.oci_core_vnic.app2.private_ip_address
  port       = 80
  weight     = 1
}

resource "oci_load_balancer_listener" "http" {
  load_balancer_id         = oci_load_balancer_load_balancer.app.id
  name                     = "http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.app.name

  port     = 80
  protocol = "HTTP"
}