locals {
  HELM_ARGO_CD_VERSION           = "7.4.2"
  HELM_ARGO_EVENTS_VERSION       = "2.4.7"
  HELM_ARGO_WORKFLOWS_VERSION    = "0.41.14"
  HELM_METRICS_SERVER_VERSION    = "3.12.1"
  HELM_PROMETHEUS_VERSION        = "25.25.0"
  HELM_STAKATER_RELOADER_VERSION = "1.0.114"
  HELM_KEEL_VERSION              = "1.0.3"
  HELM_TRAEFIK_VERSION           = "30.0.2"
  cluster_sources                = { for filename in fileset("../.tmp", "*.yaml") : filename => yamldecode(file("../.tmp/${filename}")) }
  clusters = { for key, value in local.cluster_sources : value.clusters[0].name => {
    clusterName = value.clusters[0].name
    userName    = value.users[0].name
    user        = value.users[0].user
    cluster     = value.clusters[0].cluster
  } }
}
