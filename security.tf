# NSG associated with the private Load Balancer
resource "oci_core_network_security_group" "lb" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id

  display_name = "tf-oci-refresh-lb-nsg"
}

# NSG associated with application servers
resource "oci_core_network_security_group" "app" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id

  display_name = "tf-oci-refresh-app-nsg"
}

# Clients inside the VCN can reach the private LB on HTTP
resource "oci_core_network_security_group_security_rule" "lb_ingress_http" {
  network_security_group_id = oci_core_network_security_group.lb.id

  direction   = "INGRESS"
  protocol    = "6"
  source      = var.vcn_cidr
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# LB can send HTTP traffic only to members of app-nsg
resource "oci_core_network_security_group_security_rule" "lb_to_app" {
  network_security_group_id = oci_core_network_security_group.lb.id

  direction        = "EGRESS"
  protocol         = "6"
  destination      = oci_core_network_security_group.app.id
  destination_type = "NETWORK_SECURITY_GROUP"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# Application servers accept HTTP only from members of lb-nsg
resource "oci_core_network_security_group_security_rule" "app_from_lb" {
  network_security_group_id = oci_core_network_security_group.app.id

  direction   = "INGRESS"
  protocol    = "6"
  source      = oci_core_network_security_group.lb.id
  source_type = "NETWORK_SECURITY_GROUP"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_ssh" {
  network_security_group_id = oci_core_network_security_group.app.id

  direction = "INGRESS"
  protocol  = "6"

  source      = oci_core_subnet.private.cidr_block
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}