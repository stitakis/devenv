#!/usr/bin/env bash
# Deploys the gitea as a makeshift BitBucket deployment

echo "########## running deploy-gitea.sh"

set -eu

URL=$(oc config view --minify -o jsonpath='{.clusters[*].cluster.server}')
if [ ${URL} != "https://127.0.0.1:8443" ]; then
    echo "You are not in a local cluster. Stopping now!!!"
fi

source ${BASH_SOURCE%/*}/../../ods-config/ods-core.env

cd docker/gitea
docker-compose up -d
cd -
# TODO retrieve username / password from environment variables here and in docker-compose.yml
docker container exec gitea_server_1 bash -c "gitea migrate"
docker container exec gitea_server_1 bash -c "gitea admin create-user --username cd_user --password cd_passworD1 --email cd_user@example.com --admin"

echo "########## finished deploy-gitea.sh"
