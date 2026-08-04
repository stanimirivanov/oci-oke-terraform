resource "kubernetes_namespace" "tekton_pipelines" {
  metadata {
    name = "tekton-pipelines"
  }

  depends_on = [oci_containerengine_node_pool.oke_node_pool]
}

# Install Tekton Engine via Helm / Kubernetes Manifest
resource "helm_release" "tekton_pipeline" {
  name       = "tekton-pipeline"
  repository = "https://tektoncd.github.io/charts"
  chart      = "tekton-pipeline"
  namespace  = kubernetes_namespace.tekton_pipelines.metadata[0].name
  timeout    = 300

  depends_on = [kubernetes_namespace.tekton_pipelines]
}