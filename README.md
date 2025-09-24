My self hosted stack of services and its infrastructure.

## Setup
### [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#control-node-requirements)
First it will be used to configure your local machine, then later to configure the server. 

### Obtain an AWS Access Key and a DigitalOcean API Key
You'll need two sets of credentials:

1. An AWS Access Key to store Terraform's state file remotely:
   - Go to the [AWS IAM Console](https://console.aws.amazon.com/iam/)
   - Create a new IAM user with programmatic access
   - Attach the `AmazonS3FullAccess` policy to allow managing the S3 bucket
   - Save the Access Key ID and Secret Access Key

2. A DigitalOcean API Key to create and manage cloud resources:
   - Go to the [DigitalOcean API page](https://cloud.digitalocean.com/account/api/)
   - Generate a new API token with all the droplet scopes
   - Save the token

These credentials will be used by Terraform to:
- Store its state file in AWS S3, enabling team collaboration and state locking
- Create and manage infrastructure resources in DigitalOcean

### Execute the `bootstrap` Ansible playbook
This playbook will:
1. Install Terraform on your local machine
2. Create an AWS S3 bucket to store Terraform's state file

The playbook requires sudo access to install packages and authentication to interact with AWS's API, 
so you'll be prompted for your password and the Access Key.
```bash
ansible-playbook infrastructure/ansible/playbooks/bootstrap.yaml \
    -i infrastructure/ansible/inventory.yaml \
    --ask-become-pass
```