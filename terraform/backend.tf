terraform {
  backend "kubernetes" {
    secret_suffix  = "state"
    config_path    = "~/.kube/config"
    config_context = "kind-k8s-workflows"
    namespace      = "kube-public"
  }
}