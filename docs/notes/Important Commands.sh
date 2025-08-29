# Clone Repo
git clone https://github.com/Abdullah-Mehtab/cloud-devops-lab-2025.git
cd cloud-devops-lab-2025

# Connect with your AWS - AWS CLI
aws configure
# Provide your AWS Access Key, 
# Secret Key, default region (eu-north-1), 
# and output format (json).

# Go into Terra
cd terraform

# Initialize Terraform
terraform init

# Validate (optional syntax) plan
terraform plan --out="nameofplan"

# Apply it
terraform apply "nameofplan"

# What should be done?
# Phase 1 / 2 and 3rd's first two complete

# SSH into Instances (Phase 3 Prep)

# Test by SSH into bastion
ssh -i ~/.ssh/devopsproj devops@13.61.153.223

# SSH into App Server directly 
ssh -i ~/.ssh/devopsproj -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/devopsproj devops@13.61.153.223" devops@10.0.2.168

# Exit back
# Set up Ansible
cd ../ansible
ansible-playbook -i inventory.ini ansible/sites.yml --ask-vault-pass
ansible-playbook -i inventory.ini ansible/deploy-stack.yml --ask-vault-pass
ansible-playbook -i inventory.ini ansible/configure-jenkins.yml --ask-vault-pass

# Verify services through sshing into private server and docker ps
# Check open ports
sudo ss -tulpn | grep -E ':(80|8080|9000|3000|9090|8000)'

# Run Ansible
ansible-playbook -i ansible/inventory.ini ansible/deploy-stack.yml --ask-vault-pass

# Tunnel
ssh -i ~/.ssh/devopsproj -L 8080:10.0.2.168:8080 -L 9000:10.0.2.168:9001 -L 3000:10.0.2.168:3000 -L 9090:10.0.2.168:9090 -L 8000:10.0.2.168:8000 -L 80:10.0.2.168:80 -N devops@13.61.153.223