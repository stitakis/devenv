# devenv
## Preparation steps
### Local Deployment
For local deployment create a VMWare virtual machine from CentOS-7 with these modifications
- 2+ processor cores
- 8196MB+ RAM
- Enable hypervisor applications in this virtual machine
- 40GB+ Disk size
### AWS deployment
Use the provided AWS AMI to launch an instance of the ODS development environment

## Startup
Login into the virtual machine locally or on AWS and run the provided script deploy.sh to install and startup an OpenShift cluster with ODS integration.

