#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------
#set -ex


VERSION=0.1.0
USAGE="""
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

"""


K8S_URL=$KUBE_RANCHER_URL
TOKEN=$KUBE_RANCHER_TOKEN
NAMESPACE=$KUBE_RANCHER_NAMESPACE
DEPLOYMENT=$KUBE_RANCHER_DEPLOYMENT
CONTAINER=$KUBE_CONTAINER_NAME


REGISTRY=$DOCKER_REGISTRY/$DOCKER_REPO
TAG=${TAG-latest}
FORMAT=json
DRYRUN=$(false)
DEBUG=$(false)

#trap read debug
# read the options
TEMP=`getopt -o 's:t:n:d:r:jy' --long 'registry:,server:,token:,namespace:,deployment:,dry-run,tag:,debug' -n 'test.sh' -- "$@"`
if [ $? -ne 0 ]; then
	echo $USAGE >&2
	exit 1
fi

eval set -- "$TEMP"
unset TEMP
# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -s|--server)
            K8S_URL=$2; shift 2;;
        -t|--token)
            TOKEN=$2; shift 2;;
        -n|--namespace)
            NAMESPACE=$2; shift 2;;
        -d|--deployment)
            DEPLOYMENT=$2; shift 2;;
        -r|--registry)
            REGISTRY=$2; shift 2;;
        -t|--tag)
            TAG=$2; shift 2;;
        -j)
           FORMAT=json; shift 1;;
        -y)
           FORMAT=yaml; shift 1;;
        --dry-run)
           DRYRUN=true; shift 1;;
        --tag)
           TAG=$2; shift 2;;
        --debug)
           DEBUG=true; shift 1;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

if [ $DEBUG ]; then
  set -x
  echo "setting debug"
fi

KIND=${KIND-deployment}

cmd=$1
param=$2
command="command_$1"

## chekc what is mandatory
if [ -z "$cmd" ]; then
  >&2 echo "Command is missing"
  exit 1
fi

if [ -z "$param" ] && [ -z "$PATCH_JSON" ]; then
  >&2 echo 'json|yaml|$PATCH_JSON file missing'
  exit 1
fi

PATCH_JSON=${param-$PATCH_JSON}


if [ -z "$K8S_URL" ]; then
  >&2 echo '-s / $KUBE_RANCHER_URL  is missing'
  exit 1
fi

if [ -z "$TOKEN" ]; then
  >&2 echo '-t / $KUBE_RANCHER_TOKEN  is missing'
  exit 1
fi
if [ "$REGISTRY" == "/" ]; then
  >&2 echo '-r / $DOCKER_REGISTRY/$DOCKER_REPO   is missing'
  exit 1
fi

if [ -z "$DEPLOYMENT" ]; then
  >&2 echo '-d / $KUBE_RANCHER_DEPLOYMENT  is missing'
  exit 1
fi

if [ -z "$NAMESPACE" ]; then
  >&2 echo '-n / $KUBE_RANCHER_NAMESPACE  is missing'
  exit 1
fi


IMAGE=$REGISTRY:$TAG
# -----------------------------------------------------------------
export K8S_URL TOKEN NAMESPACE DEPLOYMENT CONTAINER PATCH_JSON IMAGE
# The docker-image-version must be updated every time you built a new container.


KIND=${KIND-deployment}

if [ "$FORMAT" == "json" ];then
  yq r $PATCH_JSON > /tmp/rancher-deploy.yaml
else
   cat $PATCH_JSON > /tmp/rancher-deploy.yaml
fi
cat /tmp/rancher-deploy.yaml | envsubst  > /tmp/rancher-deploy-substituted.yaml

# -----------------------------------------------------------------


function command_patch {
    cat /tmp/rancher-deploy-substituted.yaml

    if [ $DRYRUN ]; then
      cat <<EOF
    kubectl --server=${K8S_URL} \
    --insecure-skip-tls-verify=true \
    --token=${TOKEN} \
    --namespace=${NAMESPACE} \
    patch $KIND/${DEPLOYMENT} --patch "$(cat /tmp/rancher-deploy-substituted.yaml)"
EOF
    else
     kubectl --server=${K8S_URL} \
        --insecure-skip-tls-verify=true \
        --token=${TOKEN} \
        --namespace=${NAMESPACE} \
        patch $KIND/${DEPLOYMENT} --patch "$(cat /tmp/rancher-deploy-substituted.yaml)"
    fi
}

function kubectl_apply_create {
if [ $DRYRUN ]; then
   cat /tmp/rancher-deploy-substituted.yaml
   cat << EOF
   | kubectl --server=${K8S_URL} \
    --insecure-skip-tls-verify=true \
    --token=${TOKEN} \
    --namespace=${NAMESPACE} \
    $1 -f -
EOF
else
  cat /tmp/rancher-deploy-substituted.yaml | kubectl --server=${K8S_URL} \
    --insecure-skip-tls-verify=true \
    --token=${TOKEN} \
    --namespace=${NAMESPACE} \
    $1 -f -
fi

}

function command_apply {
    kubectl_apply_create apply
}

function command_create {
    kubectl_apply_create create
}



# -----------------------------------------------------------------
if [ -n "$(type -t ${command})" ] && [ "$(type -t ${command})" = function ]; then
   ${command}
else
   echo "'${cmd}' is NOT a command";
   exit 1
fi

exit $?

