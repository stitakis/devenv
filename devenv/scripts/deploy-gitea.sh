#!/usr/bin/env bash
# Deploys the gitea as a makeshift BitBucket deployment

echo "########## running deploy-gitea.sh"

set -exu

URL=$(oc config view --minify -o jsonpath='{.clusters[*].cluster.server}')
if [ ${URL} != "https://172.17.0.1:8443" ]; then
    echo "You are not in a local cluster. Stopping now!!!"
fi

source ${BASH_SOURCE%/*}/../../ods-config/ods-core.env

docker container run -d --rm --name db \
    -e MYSQL_ROOT_PASSWORD=gitea \
    -e MYSQL_USER=gitea \
    -e MYSQL_PASSWORD=gitea \
    -e MYSQL_DATABASE=gitea \
    --volume /root/mysql_data/:/var/lib/mysql \
    mysql:5.7

docker container run -d --rm --name gitea \
    -e DB_TYPE=mysql \
    -e DB_HOST=db:3306 \
    -e DB_NAME=gitea \
    -e DB_USER=gitea \
    -e DB_PASSWD=gitea \
    -e HTTP_PORT=8080 \
    -e SSH_PORT=222 \
    -p 8080:8080 \
    --volume /root/gitea_data:/data \
    --volume /etc/timezone:/etc/timezone:ro \
    --volume /etc/localtime:/etc/localtime:ro \
    gitea/gitea:latest

echo "Waiting for gitea container to come online."
sleep 25
counter=0
while ! ps -ef | grep "gitea web" | grep -v grep; do sleep 1; counter=$((counter + 1)); done
echo "Waited for ${counter}s for gitea to come up..."

# TODO retrieve username / password from environment variables here and in docker-compose.yml
docker container exec gitea bash -c "gitea migrate"
docker container exec gitea bash -c "gitea admin create-user --username cd_user --password cd_passworD1 --email cd_user@example.com --admin"

# create test repositories
gitea_url=172.17.0.1:8080
read -n1 -r -p "Now, log into gitea under http://${gitea_url} using credentials cd_user:cd_passworD1 and press SPACE when done."
curl -X POST "http://cd_user:cd_passworD1@${gitea_url}/api/v1/user/repos" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"auto_init\": true, \"default_branch\": \"master\", \"description\": \"test setup for gitea\", \"name\": \"ods-core\", \"private\": false}" | jq .
curl -X POST "http://cd_user:cd_passworD1@${gitea_url}/api/v1/user/repos" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"auto_init\": true, \"default_branch\": \"master\", \"description\": \"test setup for gitea\", \"name\": \"ods-configuration\", \"private\": false}" | jq .
curl -X GET "http://${gitea_url}/api/v1/repos/search" -H "accept: application/json" |  jq .

echo "########## finished deploy-gitea.sh"
