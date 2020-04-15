#!/usr/bin/env bash

set -exu

echo "running init.sh"

mkdir -p $HOME/projects
cd $HOME/projects

sudo yum -y install git
git clone https://github.com/georgfedermann/devenv.git
cd devenv
find . -type f -name "*.sh" -exec chmod +x {} \;
devenv/scripts/deploy.sh

echo "finished init.sh"
