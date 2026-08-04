locals {
  # Strip hyphens and uppercase letters to comply with OCI DNS label rules
  dns_prefix = replace(lower(var.project_prefix), "-", "")
}

# Virtual Cloud Network (VCN)
resource "oci_core_vcn" "oke_vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "${var.project_prefix}-oke-vcn"
  dns_label      = "${local.dns_prefix}vcn"
}

# Internet Gateway for public connectivity
resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.project_prefix}-internet-gateway"
}

# Route Table routing Internet traffic through Internet Gateway
resource "oci_core_route_table" "rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.project_prefix}-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig.id
  }
}

# Subnet 1: Kubernetes API Endpoint
resource "oci_core_subnet" "k8s_endpoint_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.oke_vcn.id
  cidr_block        = "10.0.0.0/28"
  display_name      = "${var.project_prefix}-k8s-endpoint-subnet"
  dns_label         = "${local.dns_prefix}endpoint"
  route_table_id    = oci_core_route_table.rt.id
}

# Subnet 2: Worker Nodes Subnet
resource "oci_core_subnet" "node_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.oke_vcn.id
  cidr_block        = "10.0.10.0/24"
  display_name      = "${var.project_prefix}-node-subnet"
  dns_label         = "${local.dns_prefix}nodes"
  route_table_id    = oci_core_route_table.rt.id
}