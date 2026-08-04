terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Fetch cluster credentials dynamically for K8s & Helm providers
data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = oci_containerengine_cluster.oke_cluster.id
}

provider "kubernetes" {
  host                   = data.oci_containerengine_cluster_kube_config.oke.endpoints[0].graph_endpoint
  cluster_ca_certificate = base64decode(data.oci_containerengine_cluster_kube_config.oke.clusters[0].cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", oci_containerengine_cluster.oke_cluster.id]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.oci_containerengine_cluster_kube_config.oke.endpoints[0].graph_endpoint
    cluster_ca_certificate = base64decode(data.oci_containerengine_cluster_kube_config.oke.clusters[0].cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "oci"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", oci_containerengine_cluster.oke_cluster.id]
    }
  }
}