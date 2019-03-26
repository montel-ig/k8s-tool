# k8s-tool
CI/CD deploy helper with kubectl, curl yq and rancher-deploy script


## Docker image
montel/k8s-tool:latest

## Usage

```text
Usage: patch|apply|create [args] file.(json|yaml)


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

### Gitlab pipeline example ###
In this example all other parameters are coming from CI/CD environment
```yaml

# container is build before and stored to registry $CI_COMMIT_SHORT_SHA is 
#  used to tag freshly built image
deploy:project_staging:
  stage: deploy
  image: montel/k8s-tool
  variables:
    TAG: $CI_COMMIT_SHORT_SHA
  script:
    - export TAG
    - rancher-deploy.sh -n myproject-stage -y apply ./k8s/deployment.yaml
  only:
    - develop
  dependencies:
    - build:myproject

```

**k8s/deployment.yaml** file in project directory. All env valiables are passed in and can be used note *${IMAGE}*
```yaml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: myproject
  labels:
    app: myproject
spec:
  selector:
    matchLabels:
      app: myproject
  template:
    metadata:
      labels:
        app: myproject
    spec:
      containers:
      - image: nginx
        imagePullPolicy: IfNotPresent
        name: nginx
        ports:
        - containerPort: 80
          name: 80tcp02
          protocol: TCP
        volumeMounts:
        - mountPath: "/usr/share/nginx/html/"
          name: myproject-volume
      initContainers:
      - args:
        - bash
        - "-c"
        - "cp -rv /srv/static/_site/* /site/"
        image: "${IMAGE}"
        name: myproject
        volumeMounts:
        - mountPath: "/site"
          name: myproject-volume
      restartPolicy: Always
      volumes:
      - emptyDir: {}
        name: myproject-volume

```


*Thanks Mike for this awesome yaml tool!*

* https://github.com/mikefarah/yq