resource "kubernetes_namespace" "argo_system" {
  metadata {
    name = "argo-system"
  }
}

resource "kubernetes_namespace" "monitoring_system" {
  metadata {
    name = "monitoring-system"
  }
}

resource "kubernetes_namespace" "traefik_system" {
  metadata {
    name = "traefik-system"
  }
}

resource "null_resource" "namespaces" {
  depends_on = [
    kubernetes_namespace.argo_system,
    kubernetes_namespace.monitoring_system,
    kubernetes_namespace.traefik_system,
  ]
}
