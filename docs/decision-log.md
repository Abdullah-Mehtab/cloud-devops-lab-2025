# Decision Log - DevOps Internship Project

## Phase 1: Git & Project Setup Decisions

### 1.1 Repository Structure
**Decision**: Monolithic repository containing all infrastructure and application code
**Rationale**: 
- Easier to manage dependencies between components
- Single source of truth for entire environment
- Simplified CI/CD pipeline configuration
**Alternatives Considered**: Separate repos for infrastructure vs application code
**Trade-offs**: Larger repository size vs simplified dependency management

### 1.2 Branch Protection Rules
**Decision**: Require 2 approvals for merge to main branch
**Rationale**: 
- Ensures code quality through peer review
- Prevents accidental direct commits to main
- Enterprise-grade security practice
**Configuration**: 
- Require pull request reviews before merging
- Require status checks to pass before merging
- Include administrators in restrictions

## Phase 2: Terraform Infrastructure Decisions

### 2.1 AWS Region Selection
**Decision**: eu-north-1 (Stockholm) region
**Rationale**: 
- Cost-effective pricing compared to other regions
- Good performance for European users
- All required services available
**Alternatives**: us-east-1 (more services but higher cost)

### 2.2 VPC Design
**Decision**: 10.0.0.0/16 CIDR block with /24 subnets
**Rationale**:
- Sufficient IP space for future expansion
- Standard networking practice
- Easy to understand and manage
**Subnet Allocation**:
- Public: 10.0.1.0/24 (Bastion host)
- Private: 10.0.2.0/24 (Application servers)

### 2.3 Instance Type Selection
**Decision**: t3.micro for both bastion and app servers
**Rationale**:
- AWS Free Tier eligible
- Sufficient for development and testing
- Cost-effective for proof of concept
**Alternatives**: t3.small (more resources but not Free Tier)

### 2.4 State Management
**Decision**: S3 backend with DynamoDB locking
**Rationale**:
- Enables team collaboration
- Prevents state file conflicts
- Secure and reliable storage
**Implementation**:
- S3 bucket: tf-state-554930853385-devops-project
- DynamoDB table: terraform-state-lock

## Phase 3: Security & Automation Decisions

### 3.1 SSH Access Model
**Decision**: Bastion host jump server architecture
**Rationale**:
- Single entry point to private network
- Enhanced security through reduced attack surface
- Standard enterprise practice
**Implementation**:
- Bastion: SSH open to world (port 22)
- App servers: SSH only from bastion security group

### 3.2 User Management
**Decision**: Dedicated 'devops' user with sudo privileges
**Rationale**:
- Separation of duties from default ubuntu user
- Better audit trail for operations
- Standard security practice
**Configuration**:
- SSH key-based authentication only
- Password authentication disabled
- Root SSH login disabled

### 3.3 Secrets Management
**Decision**: Ansible Vault + AWS SSM Parameter Store
**Rationale**:
- Ansible Vault for playbook variables
- SSM for runtime credentials needed by applications
- No secrets in version control
**Implementation**:
- Jenkins credentials in SSM Parameter Store
- Ansible variables encrypted with vault

### 3.4 Firewall Configuration
**Decision**: UFW (Uncomplicated Firewall) with Fail2Ban
**Rationale**:
- Simpler than iptables for basic needs
- Fail2Ban provides brute force protection
- Easy to manage through Ansible
**Rules Configured**:
- SSH: port 22 (from appropriate sources)
- Application ports as needed

## Phase 4: Containerization & CI/CD Decisions

### 4.1 Container Orchestration
**Decision**: Docker Compose over Kubernetes
**Rationale**:
- Simpler learning curve
- Sufficient for single-server deployment
- Faster setup and iteration
**Trade-offs**: Less scalable than Kubernetes but adequate for current needs

### 4.2 Jenkins Architecture
**Decision**: Jenkins in Docker container on app server
**Rationale**:
- Consistent with containerized approach
- Easy to manage and update
- Integration with Docker socket for builds
**Challenge**: SSH key access from container to host for Ansible

### 4.3 CI/CD Pipeline Design
**Decision**: Declarative Jenkinsfile with parallelizable stages
**Rationale**:
- Infrastructure as code for pipeline
- Easy to version and review
- Clear stage separation for debugging
**Stages Implemented**:
1. Checkout → 2. Build → 3. Test → 4. SonarQube → 5. Push → 6. Deploy

### 4.4 Monitoring Stack
**Decision**: Prometheus + Grafana + CloudWatch
**Rationale**:
- Prometheus for application metrics
- Grafana for visualization
- CloudWatch for system-level monitoring
**Components**:
- Node exporters for system metrics
- Custom metrics from Python application
- Pre-built dashboards for common services

## Phase 5: unresolved Challenges

### 5.1 Jenkins to App Server SSH Connectivity
**Issue**: Jenkins container cannot authenticate to app server via SSH
**Root Cause**: SSH key mounting and permission issues in Docker volume
**Attempted Solutions**:
- Volume mount of SSH key into container
- Permission adjustments
- Alternative Ansible execution approaches
**Status**: Pending resolution - currently blocks full automation

### 5.2 SonarQube Quality Gates
**Issue**: Quality gates not fully integrated to fail pipeline
**Status**: Analysis working but quality gates not enforced

## Technology Choices Summary

| Technology | Choice | Rationale |
|------------|---------|-----------|
| Infrastructure | Terraform | Declarative, cloud-agnostic IaC |
| Configuration | Ansible | Agentless, simple YAML syntax |
| Containers | Docker | Industry standard, good ecosystem |
| Orchestration | Docker Compose | Simplicity for single host |
| CI/CD | Jenkins | Extensive plugins, pipeline as code |
| Monitoring | Prometheus+Grafana | Powerful metrics and visualization |
| Code Quality | SonarQube | Comprehensive static analysis |
| Cloud Provider | AWS | Comprehensive services, Free Tier |
| OS | Ubuntu 22.04 | Stable, well-supported |

## Future Considerations

1. **Kubernetes Migration**: If scaling beyond single server
2. **GitHub Actions**: Alternative to Jenkins for simpler workflows  
3. **Terragrunt**: For more complex Terraform configurations
4. **Vault**: For more advanced secrets management
5. **Service Mesh**: For enhanced microservices communication