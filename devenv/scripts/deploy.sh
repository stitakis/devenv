#!/usr/bin/env bash
set -eux
# this script sets up a fresh CentOS 7 installation with an ODS installation based on an OpenShift cluster started with oc cluster up

# Check whether VM is setup correctly
if [[ -z $(grep vmx /proc/cpuinfo) ]]; then
    echo "The VM needs to be configured to enable hypervisor applications. Stopping now."
    exit 1
fi
# debug log available memory and diskspace
free -m
df -h

sudo yum -y install git golang tree
sudo yum install -y docker
sudo systemctl enable --now docker

echo "updating docker insecure registries"
cat <<EOF |
{
    "bip": "172.17.0.1/16",
     "insecure-registries": [
        "172.30.0.0/16"
    ]
}
EOF
sudo tee /etc/docker/daemon.json
sudo systemctl restart docker.service

echo "Configuring firewall for docker containers:"
sudo firewall-cmd --permanent --new-zone dockerc
sudo firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
sudo firewall-cmd --permanent --zone dockerc --add-port 8443/tcp
sudo firewall-cmd --permanent --zone dockerc --add-port 53/udp
sudo firewall-cmd --permanent --zone dockerc --add-port 8053/udp
sudo firewall-cmd --reload

echo "Installing OpenShift client"
sudo yum install -y centos-release-openshift-origin311
sudo yum install -y origin-clients
source /etc/bash_completion.d/oc

echo "Starting up oc cluster for the first time"
# ip_address=192.168.188.96
ip_address=172.17.0.1
# oc cluster up --base-dir=${HOME}/openshift.local.clusterup --routing-suffix 172.17.0.1.nip.io --public-hostname 172.17.0.1 --no-proxy=172.17.0.1
sudo oc cluster up --base-dir=${HOME}/openshift.local.clusterup --routing-suffix ${ip_address}.nip.io --public-hostname ${ip_address} --no-proxy=${ip_address}
oc login -u developer
sudo oc login -u system:admin
oc projects

# TODO create a test project to verify cluster works, remove after development phase
echo "Create a simple test project to smoke test OpenShift cluster"
oc -o yaml new-app php~https://github.com/sandervanvugt/simpleapp --name=simpleapp > s2i.yaml
oc create -f s2i.yaml

echo "Download tailor"
curl -LO "https://github.com/opendevstack/tailor/releases/download/v0.13.1/tailor-linux-amd64"
chmod +x tailor-linux-amd64
sudo mv tailor-linux-amd64 /usr/bin/tailor
echo "tailor version: $(tailor version)"
echo "oc version: $(oc version)"
echo "jq version: $(jq --version)"
echo "go version: $(go version)"
echo "docker version: $(docker --version)"
echo "network interfaces: $(ip a)"

echo "Create test infrastructure"

git clone https://github.com/opendevstack/ods-core.git
cd ods-core
git checkout fix/repository-param
tests/scripts/recreate-test-infrastructure.sh
