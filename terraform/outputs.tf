output "cluster_ocid" {
  description = "OCID of the provisioned Oracle OKE Cluster"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "get_kubeconfig_command" {
  description = "OCI CLI command to fetch cluster credentials locally"
  value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.oke_cluster.id} --file ~/.kube/config --region ${var.region} --token-version 2.0.0"
}