data "oci_core_images" "oracle_linux" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = var.compute_shape

  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

variable "compute_shape" {
  description = "Compute shape for application servers"
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "ssh_public_key" {
  description = "SSH public key for compute instances"
  type        = string
}

resource "oci_core_instance" "app1" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  fault_domain        = "FAULT-DOMAIN-1"
  shape               = var.compute_shape
  display_name        = "tf-oci-refresh-app1"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-EOF
      #!/bin/bash
      dnf install -y nginx
      systemctl enable --now nginx
      firewall-cmd --permanent --add-service=http
      firewall-cmd --reload
      echo "APP1 - FD1 - Deployed by Terraform" > /usr/share/nginx/html/index.html
    EOF
    )
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.app.id]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }
}

resource "oci_core_instance" "app2" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  fault_domain        = "FAULT-DOMAIN-2"
  shape               = var.compute_shape
  display_name        = "tf-oci-refresh-app2"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-EOF
      #!/bin/bash
      dnf install -y nginx
      systemctl enable --now nginx
      firewall-cmd --permanent --add-service=http
      firewall-cmd --reload
      echo "APP2 - FD2 - Deployed by Terraform" > /usr/share/nginx/html/index.html
    EOF
    )
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.app.id]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }
}