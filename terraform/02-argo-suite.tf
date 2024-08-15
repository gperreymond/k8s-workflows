resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  version    = local.HELM_ARGO_CD_VERSION

  namespace = kubernetes_namespace.argo_system.id
  values = [
    "${file("values/argo-cd.yaml")}",
  ]

  depends_on = [
    null_resource.namespaces,
  ]
}

resource "helm_release" "argo_workflows" {
  name       = "argo-workflows"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  namespace  = kubernetes_namespace.argo_system.id
  version    = local.HELM_ARGO_WORKFLOWS_VERSION

  values = [
    "${file("values/argo-workflows.yaml")}",
  ]

  depends_on = [
    helm_release.argo_cd,
  ]
}

resource "helm_release" "argo_events" {
  name       = "argo-events"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-events"
  namespace  = kubernetes_namespace.argo_system.id
  version    = local.HELM_ARGO_EVENTS_VERSION

  values = [
    "${file("values/argo-events.yaml")}",
  ]

  depends_on = [
    helm_release.argo_cd,
  ]
}

resource "kubernetes_secret" "argo_cd_clusters" {
  for_each = { for cluster in local.clusters : cluster.clusterName => cluster }
  metadata {
    name      = each.value.clusterName
    namespace = kubernetes_namespace.argo_system.id
    labels = {
      "argocd.argoproj.io/secret-type"   = "cluster"
      "gperreymond/argocd-deployer-all"  = "true"
      "gperreymond/argocd-deployer-name" = each.value.clusterName
    }
  }
  type = "Opaque"

  data = yamldecode(<<YAML
name: "${each.value.clusterName}"
server: "${split(":", each.value.cluster.server)[0]}:${split(":", each.value.cluster.server)[1]}:6443"
config: |
  {
    "username": "${each.value.userName}",
    "tlsClientConfig": {
      "insecure": false,
      "caData": "${each.value.cluster["certificate-authority-data"]}",
      "certData": "${each.value.user["client-certificate-data"]}",
      "keyData": "${each.value.user["client-key-data"]}"
    }
  }
YAML
  )

  depends_on = [
    helm_release.argo_cd,
  ]
}

resource "kubernetes_manifest" "argocd_projects" {
  for_each = { for filepath in fileset("./argo-cd/projects", "*.yaml") : filepath => filepath }

  manifest = yamldecode(templatefile("./argo-cd/projects/${each.key}", {
    argo_cd_namespace = kubernetes_namespace.argo_system.id
  }))

  depends_on = [
    helm_release.argo_cd,
  ]
}

resource "kubernetes_manifest" "argocd_applications" {
  for_each = { for filepath in fileset("./argo-cd/applications", "*.yaml") : filepath => filepath }

  manifest = yamldecode(templatefile("./argo-cd/applications/${each.key}", {
    argo_cd_namespace     = kubernetes_namespace.argo_system.id
    monitoring_namespace  = kubernetes_namespace.monitoring_system.id
    kube_system_namespace = "kube-system"
    traefik_namespace     = kubernetes_namespace.traefik_system.id
    clusters              = local.clusters
    metricsServer = {
      targetRevision = local.HELM_METRICS_SERVER_VERSION
    }
    prometheus = {
      targetRevision = local.HELM_PROMETHEUS_VERSION
    }
    stakaterReloader = {
      targetRevision = local.HELM_STAKATER_RELOADER_VERSION
    }
    keel = {
      targetRevision = local.HELM_KEEL_VERSION
    }
    traefik = {
      targetRevision = local.HELM_TRAEFIK_VERSION
    }
  }))

  depends_on = [
    helm_release.argo_cd,
    helm_release.argo_workflows,
    helm_release.argo_events,
    kubernetes_secret.argo_cd_clusters,
    kubernetes_manifest.argocd_projects,
  ]
}

resource "null_resource" "argo_suite" {
  depends_on = [
    helm_release.argo_cd,
    helm_release.argo_workflows,
    helm_release.argo_events,
    kubernetes_secret.argo_cd_clusters,
    kubernetes_manifest.argocd_projects,
    kubernetes_manifest.argocd_applications,
  ]
}
