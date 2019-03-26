# k8s-tool
CI/CD deploy helper with kubectl and others

## Docker image
montel/k8s-tool:latest

## Usage

```bash
Usage: pathc|apply|create [args] file.(json|yaml)


-s, --server          Kubernetes cluster/ Rancher API (\$KUBE_RANCHER_URL)
-t, --token           Rancher auth token (\$KUBE_RANCHER_TOKEN)
-r, --registry        Docker registry (\$DOCKER_REGISTRY/\$DOCKER_REPO) )

-n, --namespace       Namespace for deployment (\$KUBE_RANCHER_NAMESPACE )
-d, --deployment      Deployment ( \$KUBE_RANCHER_DEPLOYMENT )
    --tag             image tag ( \$TAG )
-j                    Format json
-y                    Format yaml

    --dry-run          Show what is to be done

Example:
export KUBE_RANCHER_DEPLOYMENT=mypdoject
export KUBE_RANCHER_NAMESPACE=stage
rancher-deploy.sh -s https://rancher/k8s -t mysecrettoken -r registry.gitlab.com/myproject --tag v1.2.3 -y --dry-run apply patch.yaml

```