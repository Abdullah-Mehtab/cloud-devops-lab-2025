# Setup Guide

## Phase 1: Git & Project Setup - COMPLETED ✅
- GitHub repository created
- Branch protection rules configured
- Kanban board setup
- Issue templates added

## Phase 2: Terraform AWS Setup - COMPLETED ✅

### Infrastructure Created
- **VPC**: `10.0.0.0/16` in eu-north-1
- **Public Subnet**: `10.0.1.0/24` (bastion host - 13.61.153.223)
- **Private Subnet**: `10.0.2.0/24` (app server - 10.0.2.168)
- **Internet Gateway**: Configured for public internet access
- **NAT Gateway**: Configured with EIP 13.60.126.146 for private subnet internet access
- **EC2 Instances**: t3.micro Ubuntu instances (Free Tier compliant)
- **State Management**: S3 bucket with versioning and DynamoDB locking

### Security Configuration
- Security groups with least privilege access
- SSH key authentication configured

## Phase 3: Security & Automation - COMPLETED ✅

### Terraform Enhancements
- **IAM Role**: `devops-project-ec2-role` with S3 and CloudWatch access
- **SSM Parameter Store**: Jenkins credentials securely stored (`/jenkins/user` and `/jenkins/password`)

### Ansible Configuration
- **Software Installed**: Docker, Docker Compose, Python 3.10.12 on both instances
- **Security Hardening**:
  - UFW firewall configured (SSH allowed, port 8000 on app server)
  - Fail2Ban installed for SSH protection
  - DevOps user created with SSH key access
  - Root SSH login disabled
  - Password authentication disabled
- **Secrets Management**: Ansible Vault implemented for sensitive data

### Access Configuration
- Bastion host accessible via SSH at 13.61.153.223
- App server accessible only via bastion host at 10.0.2.168
- DevOps user with sudo and docker privileges on both instances

## Verification
All infrastructure components validated through AWS CLI commands and SSH access tests.