#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------
set -ex
#trap read debug
#trap 'do_something' ERR
function do_something {
    echo "Error!"
    exit 1
}



VERSION=0.1.0
USAGE="Usage: pathc|apply|create [args] file.(json|yaml)"


K8S_URL=$KUBE_RANCHER_URL
TOKEN=$KUBE_RANCHER_TOKEN
NAMESPACE=$KUBE_RANCHER_NAMESPACE
DEPLOYMENT=$KUBE_RANCHER_DEPLOYMENT
CONTAINER=$KUBE_CONTAINER_NAME
PATCH_JSON=${PATCH_JSON-patch.json}

REGISTRY=$DOCKER_REGISTRY/$DOCKER_REPO
TAG=latest

# read the options
TEMP=`getopt -o :s:t:n:d:u: --long server:,token:,namespace:,deployment: -n 'test.sh' -- "$@"`
eval set -- "$TEMP"
function shiftParams(){
shift $1
}
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


        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

PATCH_JSON=${PATCH_JSON-patch.json}
KIND=${KIND-deployment}


cmd=$1
param=$2
command="command_$1"

## chekc what is mandatory
if [ -z "$cmd" ]; then
  >&2 echo "Command is missing"
  exit 1
fi

if [ -z "$K8S_URL" ]; then
  >&2 echo '-s / $KUBE_RANCHER_URL  is missing'
  exit 1
fi

if [ -z "$TOKEN" ]; then
  >&2 echo '-t / $KUBE_RANCHER_TOKEN  is missing'
  exit 1
fi
if [ -z "$REGISTRY" ]; then
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

# -----------------------------------------------------------------
function command_apply {
    echo "test"
}

function command_patch {
cat <<EOF
    kubectl --server=${K8S_URL} \
    --insecure-skip-tls-verify=true \
    --token=${TOKEN} \
    --namespace=${NAMESPACE} \
    patch $KIND/${DEPLOYMENT} --patch '%'
EOF
}

set -x

IMAGE=$REGISTRY:$TAG
# -----------------------------------------------------------------
export K8S_URL TOKEN NAMESPACE DEPLOYMENT CONTAINER PATCH_JSON IMAGE
# The docker-image-version must be updated every time you built a new container.

PATCH_JSON=${PATCH_JSON-patch.json}
KIND=${KIND-deployment}
cat $PATCH_JSON | envsubst  > /tmp/rancher-deploy.yaml
cat /tmp/rancher-deploy.yaml


# -----------------------------------------------------------------
if [ -n "$(type -t ${command})" ] && [ "$(type -t ${command})" = function ]; then
   ${command}
else
   echo "'${cmd}' is NOT a command";
fi



exit 1

set -o xtrace

# Get the K8S_URL and Token from Rancher Cluster level Kubeconfig (logged in as the CI user)
export K8S_URL=$KUBE_RANCHER_URL
export TOKEN=$KUBE_RANCHER_TOKEN
export NAMESPACE=$KUBE_RANCHER_NAMESPACE

# Typically these are identical. Check from the YAML file of your deployment.
export DEPLOYMENT=$KUBE_RANCHER_DEPLOYMENT
export CONTAINER=$KUBE_CONTAINER_NAME

# The docker-image-version must be updated every time you built a new container.
export IMAGE=$DOCKER_REGISTRY/$DOCKER_REPO:$TAG
PATCH_JSON=${PATCH_JSON-patch.json}
KIND=${KIND-deployment}

#preview json
cat $PATCH_JSON | envsubst | cat
# flatten JSON to oneliner and run envsubst
cat $PATCH_JSON | envsubst | tr -d '\n\r' |xargs -I % kubectl --server=${K8S_URL} \
    --insecure-skip-tls-verify=true \
    --token=${TOKEN} \
    --namespace=${NAMESPACE} \
    patch $KIND/${DEPLOYMENT} --patch '%'
