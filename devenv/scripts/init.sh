#!/usr/bin/env bash
mkdir -p $HOME/projects
cd $HOME/projects

git clone https://github.com/georgfedermann/devenv.git
cd devenv
scripts/deploy.sh
