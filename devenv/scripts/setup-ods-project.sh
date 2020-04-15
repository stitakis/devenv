#!/usr/bin/env bash

# Create the namespace for holding all ODS resources

set -ue

function usage {
   printf "usage: %s [options]\n" $0
   printf "\t--non-interactive\tDon't ask for user confirmation\n"
   printf "\t-h|--help\tPrint usage\n"
   printf "\t-v|--verbose\tVerbose output\n"
   printf "\t-t|--tailor\tChange executable of tailor. Default: tailor\n"

}
TAILOR="tailor"
NAMESPACE="cd"
NON_INTERACTIVE=""

while [[ "$#" -gt 0 ]]; do case $1 in

   -v|--verbose) set -x;;

   -h|--help) usage; exit 0;;

   --non-interactive) NON_INTERACTIVE="--non-interactive"; ;;

   -t=*|--tailor=*) TAILOR="${1#*=}";;
   -t|--tailor) TAILOR="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
 esac; shift; done

if ! oc whoami > /dev/null; then
  echo "You must be logged into OpenShift to run this script"
  exit 1
fi

# Create namespace
if oc project ${NAMESPACE}; then
  echo "The project '${NAMESPACE}' already exists"
else
  echo "Creating project '${NAMESPACE}' ..."
  oc new-project ${NAMESPACE} --description="Central ODS namespace with shared resources" --display-name="OpenDevStack"
fi

# Allow system:authenticated group to pull images from CD namespace
oc adm policy add-cluster-role-to-group system:image-puller system:authenticated -n ${NAMESPACE}
oc adm policy add-role-to-group view system:authenticated -n ${NAMESPACE}

# Create  global cd_user secret
cd ${BASH_SOURCE%/*}/ocp-config/cd-user
${TAILOR} -n ${NAMESPACE} apply ${NON_INTERACTIVE}
cd -
