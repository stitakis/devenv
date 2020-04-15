#!/usr/bin/env bash
# Deploys the gitea as a makeshift BitBucket deployment

set -eu

URL=$(oc config view --minify -o jsonpath='{.clusters[*].cluster.server}')
if [ ${URL} != "https://127.0.0.1:8443" ]; then
    echo "You are not in a local cluster. Stopping now!!!"
fi

source ${BASH_SOURCE%/*}/../../ods-config/ods-core.env

cd docker/gitea
docker-compose up -d
cd -
