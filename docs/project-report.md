# Cloud DevOps Project Report 2025

## Table of Contents
1. [Project Overview](#project-overview)
2. [Infrastructure Components](#infrastructure-components)
3. [Security Implementation](#security-implementation)
4. [Automation and Configuration](#automation-and-configuration)
5. [Current Status and Next Steps](#current-status-and-next-steps)

## Project Overview

### Project Structure
```
cloud-devops-lab-2025/
├── ansible/
│   ├── group_vars/all/vault.yml
│   ├── inventory.ini
│   └── site.yml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── vpc/
│       ├── security/
│       └── ec2/
└── docs/
```

## Infrastructure Components

### AWS Resources

#### VPC Configuration
- **CIDR Block**: `10.0.0.0/16`
- **Region**: eu-north-1 (Stockholm)
- **Subnets**:
  - Public: `10.0.1.0/24` (Bastion Host)
  - Private: `10.0.2.0/24` (Application Server)

#### Network Components
- **Internet Gateway**: Enables public subnet internet access
- **NAT Gateway**: 
  - EIP: 13.60.126.146
  - Enables private subnet outbound internet access
  - Cost-optimized: Single NAT Gateway for all private subnets

#### EC2 Instances
1. **Bastion Host**:
   - Public IP: 13.61.153.223
   - Instance Type: t3.micro (Free Tier)
   - AMI: Ubuntu 22.04 LTS
   - Subnet: Public
   - Purpose: Secure entry point to private network

2. **Application Server**:
   - Private IP: 10.0.2.168
   - Instance Type: t3.micro (Free Tier)
   - AMI: Ubuntu 22.04 LTS
   - Subnet: Private
   - Purpose: Main application hosting

### State Management
- **Backend**: S3
  - Bucket: tf-state-554930853385-devops-project
  - Key: terraform.tfstate
  - Region: eu-north-1
- **State Locking**: DynamoDB
  - Table: terraform-state-lock
  - Billing Mode: PAY_PER_REQUEST

## Security Implementation

### Network Security

#### Security Groups
1. **Bastion Host Security Group**:
   - Inbound:
     - SSH (22): 0.0.0.0/0
   - Outbound:
     - All traffic: 0.0.0.0/0

2. **Application Server Security Group**:
   - Inbound:
     - SSH (22): Bastion SG
     - HTTP (8000): 0.0.0.0/0
   - Outbound:
     - All traffic: 0.0.0.0/0

### IAM Configuration

#### EC2 Instance Role
- **Role Name**: devops-project-ec2-role
- **Policies**:
  - S3 Full Access
  - CloudWatch Full Access
- **Instance Profile**: Applied to both EC2 instances

### Server Security

#### UFW Firewall Rules
- Default: Deny all incoming
- Allowed ports:
  - SSH (22) on all instances
  - HTTP (8000) on app server only

#### Fail2Ban Configuration
- Service: Enabled and running
- SSH protection:
  - Max retries: 3
  - Ban time: 600 seconds
  - Log path: /var/log/auth.log

#### SSH Hardening
- Root login: Disabled
- Password authentication: Disabled
- Key-based authentication: Enforced

### Secrets Management

#### Ansible Vault
- Location: ansible/group_vars/all/vault.yml
- Contents: Encrypted sensitive data including password hashes

#### AWS Systems Manager
- Parameter Store entries:
  - /jenkins/user (String)
  - /jenkins/password (SecureString)
- Auto-generated secure password using random_password resource

## Automation and Configuration

### Terraform Modules

#### VPC Module
- Creates complete networking stack
- Handles subnet creation and routing
- Manages internet and NAT gateways

#### Security Module
- Manages security groups
- Handles IAM role creation
- Creates and manages SSM parameters
- Imports existing SSH key pair

#### EC2 Module
- Provisions instances
- Configures instance profiles
- Manages instance metadata

### Ansible Configuration

#### Software Installation
- Docker Engine
- Docker Compose (v2.27.1)
- Python 3.10.12
- UFW Firewall
- Fail2Ban

#### User Management
- Created devops user:
  - Groups: sudo, docker
  - SSH key authentication
  - No password login

#### Directory Structure
```
/home/devops/apps/
├── python-app/
├── html-app/
└── nginx/
```

## Current Status and Next Steps

### Completed Phases
1. ✅ Git & Project Setup
2. ✅ Terraform AWS Setup
3. ✅ Security & Automation

### In Progress
4. 🚧 Containerization & CI/CD
   - Docker Compose services planning
   - Jenkins pipeline design
   - SonarQube integration preparation

### Planned Services
- Jenkins with persistent volume
- SonarQube + Postgres
- Grafana + Prometheus
- Nginx reverse proxy

### Next Steps
1. Complete Docker Compose configuration
2. Set up Jenkins declarative pipeline
3. Implement monitoring stack
4. Configure reverse proxy routing

## Cost Optimization

### Current Measures
1. **Compute**:
   - Using t3.micro instances (Free Tier)
   - Minimal EBS volumes

2. **Networking**:
   - Single NAT Gateway
   - Strategic region selection

3. **Database**:
   - DynamoDB with PAY_PER_REQUEST billing

### Monitoring
- All resources tagged for cost tracking
- CloudWatch integration ready for metric collection

---

*Report generated on August 27, 2025*
