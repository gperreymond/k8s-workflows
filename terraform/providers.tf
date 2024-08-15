provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-k8s-workflows"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-k8s-workflows"
  }
}
