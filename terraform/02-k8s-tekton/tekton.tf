resource "kubernetes_namespace" "tekton_pipelines" {
  metadata {
    name = "tekton-pipelines"
  }
}

resource "helm_release" "tekton_pipeline" {
  name       = "tekton-pipeline"
  repository = "https://cdfoundation.github.io/tekton-helm-chart/"
  chart      = "tekton-pipeline"
  namespace  = kubernetes_namespace.tekton_pipelines.metadata[0].name

  depends_on = [
    kubernetes_namespace.tekton_pipelines
  ]
}
