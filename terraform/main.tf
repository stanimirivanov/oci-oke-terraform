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

# Create a local variable to decode the raw YAML content
locals {
  kubeconfig = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)
}

# Update the Kubernetes provider
provider "kubernetes" {
  host                   = local.kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])

  # OKE typically requires the OCI CLI for authentication.
  # If you are using the default exec configuration, add this:
  exec {
    api_version = local.kubeconfig.users[0].user.exec.apiVersion
    args        = local.kubeconfig.users[0].user.exec.args
    command     = local.kubeconfig.users[0].user.exec.command
  }
}

# Update the Helm provider
provider "helm" {
  kubernetes {
    host                   = local.kubeconfig.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])

    exec {
      api_version = local.kubeconfig.users[0].user.exec.apiVersion
      args        = local.kubeconfig.users[0].user.exec.args
      command     = local.kubeconfig.users[0].user.exec.command
    }
  }
}