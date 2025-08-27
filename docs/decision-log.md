# Decision Log

## Technology Choices

### Terraform
Chosen for Infrastructure as Code due to:
- Multi-cloud capability
- Large community support
- Declarative configuration syntax
- State management capabilities

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

## Phase 2 & 3 Architecture Decisions

### Terraform Design Choices
- **Modular Structure**: Separate VPC, security, and EC2 modules for reusability
- **State Management**: S3 backend with DynamoDB locking for team collaboration
- **Networking**: NAT Gateway for cost-effective outbound internet from private subnet
- **Instance Selection**: t3.micro instances for Free Tier compliance

### Security Decisions
- **Least Privilege**: Security groups allow only necessary ports (SSH and HTTP)
- **IAM Roles**: EC2 instances use roles instead of hardcoded credentials
- **SSM Parameter Store**: Secure storage for Jenkins credentials instead of hardcoding
- **SSH Hardening**: Disabled root login and password authentication

### Ansible Implementation
- **Simplified Authentication**: SSH key-only access for devops user (more secure than passwords)
- **Bastion Pattern**: Single entry point to private network for enhanced security
- **Idempotent Configuration**: Ansible playbooks can be run multiple times safely

### Cost Optimization
- **Free Tier Resources**: t3.micro instances, minimal EBS storage
- **Single NAT Gateway**: Shared across all private subnets to minimize costs
- **On-Demand Pricing**: DynamoDB with PAY_PER_REQUEST billing

## Phase 4 Architecture Decisions

### Container Orchestration
- Using **Docker Compose** to define and manage multi-container stack for local and EC2 deployment.
- Persistent volumes chosen for:
  - Jenkins (job history, plugins, configs)
  - SonarQube + Postgres (code quality data)
  - Prometheus (metrics storage)

### Service Integration
- **Nginx reverse proxy** to expose multiple services under distinct paths (`/jenkins`, `/sonar`, `/grafana`).
- Centralized logging planned for Jenkins, SonarQube, and Prometheus.

### CI/CD Strategy
- Jenkins declarative pipeline will:
  - Build Flask app Docker image
  - Run linting + unit tests
  - Push to DockerHub
  - Trigger deployment on AWS EC2 via Ansible