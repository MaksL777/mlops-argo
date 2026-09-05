resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "infra-tools"
  create_namespace = true
  version          = "7.4.4"
  wait             = false

  values = [
    file("${path.module}/values/argocd-values.yaml")
  ]
}
