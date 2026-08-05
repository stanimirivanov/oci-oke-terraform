output "cluster_ocid" {
  description = "OCID of the provisioned Oracle OKE Cluster"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "region" {
  description = "OCI Region"
  value       = var.region
}