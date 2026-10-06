variable "bastion_client_cidr" {
  description = "Public client CIDR allowed to connect through OCI Bastion"
  type        = string
}

resource "oci_bastion_bastion" "main" {
  bastion_type = "STANDARD"

  compartment_id   = var.compartment_ocid
  target_subnet_id = oci_core_subnet.private.id

  name = "tf-oci-refresh-bastion"

  client_cidr_block_allow_list = [
    var.bastion_client_cidr
  ]

  freeform_tags = {
    Purpose     = "OCI-Refresh"
    Environment = "Training"
  }
}