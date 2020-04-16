#!/usr/bin/env bash
set -eu

echo "########## running setup-mocked-ods-repo.sh"

function usage {
   printf "usage: %s [options]\n", $0
   printf "\t-h|--help\tPrints the usage\n"
   printf "\t-v|--verbose\tVerbose output\n"
   printf "\t-b|--ods-ref\tReference to be created in the git repo.\n"

}

urlencode() {
    # urlencode <string>

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done


}

REF=""

URL=$(oc config view --minify -o jsonpath='{.clusters[*].cluster.server}')
if [ ${URL} != "https://172.17.0.1:8443" ]; then
    echo "You are not in a local cluster. Stopping now!!!"
    exit 1
fi

while [[ "$#" -gt 0 ]]; do case $1 in

   -v|--verbose) set -x;;

   -h|--help) usage; exit 0;;

   -b=*|--ods-ref=*) REF="${1#*=}";;
   -b|--ods-ref) REF="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
 esac; shift; done

if git remote -v | grep gitea; then
    git remote remove gitea
fi


if [ -z "${REF}" ]; then
    echo "Reference --ods-ref must be provided"
    exit 1
fi

source ${BASH_SOURCE%/*}/../../ods-config/ods-core.env

docker ps | grep gitea

# git checkout -b "${REF}"
HEAD=$(git rev-parse --abbrev-ref HEAD)
if [ "${HEAD}" = "HEAD" ]; then
    HEAD="cicdtests"
    git checkout -b ${HEAD}
fi

current_pwd=$(pwd)
gitea_url="http://$(urlencode ${CD_USER_ID}):$(urlencode ${CD_USER_PWD})@${BITBUCKET_HOST}/$(urlencode ${CD_USER_PWD})/ods-core.git"
echo "gitea URL for ods-core is ${gitea_url}"
ods_core_base_path=${HOME}/projects/
mkdir -p ${ods_core_base_path}
cd ${ods_core_base_path}
git clone https://github.com/opendevstack/ods-core.git
cd ods-core

git remote add gitea ${gitea_url}
git -c http.sslVerify=false push gitea --set-upstream "${HEAD}:${REF}"
git remote remove gitea


mkdir -p "${BASH_SOURCE%/*}/../../../ods-configuration"
cp ${BASH_SOURCE%/*}/../../ods-config/ods-core.env ${BASH_SOURCE%/*}/../../../ods-configuration

cd "${BASH_SOURCE%/*}/../../../ods-configuration"
git init
git config user.email "test@suite.nip.io"
git config user.name "Test Suite"
git add ods-core.env
git commit -m "Initial Commit"
git remote add gitea "http://$(urlencode ${CD_USER_ID}):$(urlencode ${CD_USER_PWD})@${BITBUCKET_HOST}/$(urlencode ${CD_USER_PWD})/ods-configuration.git"
git -c http.sslVerify=false push gitea --set-upstream "$(git rev-parse --abbrev-ref HEAD):${REF}"
cd $current_pwd

echo "########## finished setup-mocked-ods-repo.sh"
