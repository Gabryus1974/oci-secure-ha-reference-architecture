variable "tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

output "availability_domains" {
  value = data.oci_identity_availability_domains.ads.availability_domains[*].name
}

data "oci_identity_fault_domains" "fds" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.tenancy_ocid
}

output "failure_domains" {
  value = data.oci_identity_fault_domains.fds.fault_domains[*].name
}