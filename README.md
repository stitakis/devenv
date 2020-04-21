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
- Login to the AWS Management Console
- Select the EC2 Service from the Services -> Compute -> EC2
- Click the button "Launch instance"
- From "My AMIs" select "AWS-VMImport service: Linux - CentOS Linux release 7.7.1908 (Core)" - TODO improve AMI naming
- Choose an Instance Type with at least 8GiB Memory and at least 2 vCPUs (e.g. t2.large)
- Configure at least 40GiB disk size
- Create a key pair required to log into the EC2 instance and store the pem file locally
- The security group launch-wizard-2 should be used
    - opens port 22 for ssh connections
    - opens port range 5900-5920 for VNC connections to support RDP
- Launch the EC2 instance
- Review the EC2 instance details and take note of
    - the path to the key pem file PATH_TO_PEM_FILE
    - the public DNS of the new EC2 instance EC2_PUBLIC_DNS
- When the EC2 instance has become available you can log into the vm
    - ssh: ssh -i PATH_TO_PEM_FILE.pem openshift@EC2_PUBLIC_DNS

## Startup
Login into the virtual machine locally or on AWS and run the provided script deploy.sh to install and startup an OpenShift cluster with ODS integration.

systemctl damon-reload
systemctl start vncserver@:1.service
See "systemctl status vncserver@:1.service" and "journalctl -xe" for details.