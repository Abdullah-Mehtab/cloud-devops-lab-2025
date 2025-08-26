# Decision Log

## Technology Choices

### Terraform
Chosen for Infrastructure as Code due to:
- Multi-cloud capability
- Large community support
- Declarative configuration syntax
- State management capabilities

## Terraform Architecture Decisions

### Module Structure
Used modular approach for better organization and reusability:
- VPC module: Networking infrastructure
- Security module: Security groups and key pairs
- EC2 module: Instance provisioning

### State Management
- S3 backend with versioning for state persistence
- DynamoDB for state locking to prevent conflicts
- Encryption enabled for security

### Networking Design
- VPC with public and private subnets
- NAT Gateway for outbound internet from private subnet
- Restricted security groups following least privilege principle

### Instance Selection
- t3.micro instances: Free Tier eligible and cost-effective
- Ubuntu 22.04 LTS: Stable and well-supported
- Existing SSH key: Reuse instead of creating new key

### Ansible
Selected for configuration management because:
- Agentless architecture
- YAML-based playbooks (readable)
- Idempotent operations
- Strong AWS integration

### Docker Compose
Used for container orchestration for:
- Simplified multi-container management
- Development-production parity
- Network isolation capabilities