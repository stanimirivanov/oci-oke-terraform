# ==============================================================================
# Data Sources: Dynamic Region, Version & Image Lookup
# ==============================================================================

# Get Availability Domains in the active region
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Get supported Kubernetes versions for OKE
data "oci_containerengine_cluster_option" "oke_options" {
  cluster_option_id = "all"
  compartment_id    = var.compartment_ocid
}

# Get available node pool OS images
data "oci_containerengine_node_pool_option" "node_options" {
  node_pool_option_id = "all"
  compartment_id      = var.compartment_ocid
}

locals {
  # Select the latest Kubernetes version supported by OKE
  kubernetes_version = reverse(sort(data.oci_containerengine_cluster_option.oke_options.kubernetes_versions))[0]

  # Target official OKE worker images for ARM (aarch64) architecture
  arm_node_images = [
    for image in data.oci_containerengine_node_pool_option.node_options.sources :
    image.image_id if length(regexall("aarch64.*OKE|Oracle-Linux-.*aarch64", image.source_name)) > 0
  ]
  node_image_id = length(local.arm_node_images) > 0 ? local.arm_node_images[0] : data.oci_containerengine_node_pool_option.node_options.sources[0].image_id
}

# ==============================================================================
# OKE Cluster (Basic Cluster = $0/month)
# ==============================================================================

resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_ocid
  name               = "${var.project_prefix}-oke-cluster"
  kubernetes_version = local.kubernetes_version
  vcn_id             = oci_core_vcn.oke_vcn.id
  type               = "BASIC_CLUSTER"

  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.k8s_endpoint_subnet.id
    nsg_ids              = [oci_core_network_security_group.api_endpoint_nsg.id]
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
    }
    admission_controller_options {
      is_pod_security_policy_enabled = false
    }
  }
}

# ==============================================================================
# Node Pool (Ampere A1 ARM - Always Free Sizing)
# ==============================================================================

resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_ocid
  name               = "${var.project_prefix}-arm-pool"
  kubernetes_version = local.kubernetes_version
  node_shape         = "VM.Standard.A1.Flex" # Always Free Ampere ARM Flex Shape

  # Always Free Allowance Limit: 4 OCPUs and 24 GB RAM total across tenancy.
  # Split across size = 2 nodes: 2 OCPUs & 12 GB RAM per node.
  node_shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  node_source_details {
    image_id    = local.node_image_id
    source_type = "IMAGE"
  }

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.node_subnet.id
    }
    nsg_ids = [oci_core_network_security_group.node_nsg.id]
    size    = 2

    # Add required pod network configuration to match OCI_VCN_IP_NATIVE CNI
    node_pool_pod_network_option_details {
      cni_type       = "OCI_VCN_IP_NATIVE"
      pod_subnet_ids = [oci_core_subnet.pod_subnet.id]
    }
  }

  initial_node_labels {
    key   = "node-role"
    value = "${var.project_prefix}-worker"
  }
}