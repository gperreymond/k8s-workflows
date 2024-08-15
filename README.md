# K8S WORKFLOWS

## Creation: Kubernetes cluster

```sh
# start kubernetes
$ devbox run kube:start
# stop the cluster
$ devbox run kube:stop
```

## Provisionning: Kubernetes cluster

```sh
# get the kubeconfig => for argo-cd clusters secrets
devbox run kube:config
# because of issue: https://github.com/hashicorp/terraform-provider-kubernetes/issues/1583
$ devbox run kube:terraform init
$ devbox run kube:terraform apply -target helm_release.argo_cd
# once the target is done, you can do:
$ devbox run kube:terraform [apply, plan, etc]
```

* https://traefik.docker.localhost/dashboard/
* https://argo-cd.docker.localhost
* https://argo-workflows.docker.localhost
