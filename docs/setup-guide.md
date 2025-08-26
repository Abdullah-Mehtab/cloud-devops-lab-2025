# Setup Guide

## Phase 1: Git & Project Setup
- [x] GitHub repository created
- [x] Branch protection rules configured
- [x] Kanban board setup
- [x] Issue templates added

## Phase 2: Terraform AWS Setup

### Infrastructure Created
- ✅ VPC with CIDR block 10.0.0.0/16
- ✅ Public subnet (10.0.1.0/24) for bastion host
- ✅ Private subnet (10.0.2.0/24) for application server
- ✅ Internet Gateway and NAT Gateway
- ✅ EC2 instances (t3.micro):
  - Bastion host in public subnet
  - Application server in private subnet
- ✅ Terraform state stored in S3 with DynamoDB locking

### Security Configuration
- ✅ Security groups with restricted access
- ✅ SSH key pair for secure access
- ✅ Minimal open ports (SSH and HTTP only)

### Cost Considerations
- Using t3.micro instances (Free Tier eligible)
- Single NAT Gateway to minimize costs
- Resources tagged for cost tracking