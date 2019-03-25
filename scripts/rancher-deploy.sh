#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------
set -x
trap read debug

SUBJECT=some-unique-id
VERSION=0.1.0
USAGE="Usage: pathc|apply|create [args] file.(json|yaml)"


K8S_URL=$KUBE_RANCHER_URL
TOKEN=$KUBE_RANCHER_TOKEN
NAMESPACE=$KUBE_RANCHER_NAMESPACE
DEPLOYMENT=$KUBE_RANCHER_DEPLOYMENT
CONTAINER=$KUBE_CONTAINER_NAME


# read the options
TEMP=`getopt -o :s:t: --long server:,token: -n 'test.sh' -- "$@"`
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
        -c|--argc)
            case "$2" in
                "") shift 2 ;;
                *) ARG_C=$2 ; shift 2 ;;
            esac ;;

        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done


cmd=$1
param=$2
command="command_$1"

# -----------------------------------------------------------------
LOCK_FILE=/tmp/${SUBJECT}.lock

if [ -f "$LOCK_FILE" ]; then
echo "Script is already running"
exit
fi

# -----------------------------------------------------------------
trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE

# -----------------------------------------------------------------
function command_test {
    echo "test"
}

function command_ping {
    echo "ping $param"
}

# -----------------------------------------------------------------
# -----------------------------------------------------------------
if [ -n "$(type -t ${command})" ] && [ "$(type -t ${command})" = function ]; then
   ${command}
else
   echo "'${cmd}' is NOT a command";
fi



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
