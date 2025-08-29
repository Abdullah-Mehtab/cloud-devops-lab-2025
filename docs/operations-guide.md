# Operations Guide - DevOps Internship Project

## Table of Contents
1. [System Overview](#system-overview)
2. [Access Management](#access-management)
3. [Monitoring & Alerting](#monitoring--alerting)
4. [Backup & Recovery](#backup--recovery)
5. [Troubleshooting](#troubleshooting)
6. [Maintenance Procedures](#maintenance-procedures)
7. [Security Procedures](#security-procedures)

## System Overview

### Infrastructure Components
- **VPC**: 10.0.0.0/16 in eu-north-1
- **Bastion Host**: 13.61.153.223 (Public)
- **App Server**: 10.0.2.168 (Private)
- **S3 Bucket**: tf-state-554930853385-devops-project
- **DynamoDB Table**: terraform-state-lock

### Application Services
| Service | Port | URL | Purpose |
|---------|------|-----|---------|
| Jenkins | 8080 | http://localhost:8080 | CI/CD Pipeline |
| SonarQube | 9001 | http://localhost:9001 | Code Quality |
| Grafana | 3000 | http://localhost:3000 | Monitoring Dashboards |
| Prometheus | 9090 | http://localhost:9090 | Metrics Collection |
| Python App | 8000 | http://localhost:8000 | Flask Application |
| Nginx | 80 | http://localhost | Reverse Proxy |

## Access Management

### SSH Access
```bash
# Access bastion host
ssh -i ~/.ssh/devopsproj devops@13.61.153.223

# Access app server through bastion
ssh -i ~/.ssh/devopsproj -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/devopsproj devops@13.61.153.223" devops@10.0.2.168
```

### Service Credentials
- **Jenkins**: Credentials stored in AWS SSM Parameter Store
- **SonarQube**: Default admin/admin (change in production)
- **Grafana**: Default admin/admin (change in production)

### AWS Access
- IAM User: DevOpsProj
- Permissions: EC2, VPC, S3, DynamoDB, SSM access
- Region: eu-north-1

## Monitoring & Alerting

### Key Metrics to Monitor

#### System Metrics
- CPU Utilization (alert >70%)
- Memory Usage (alert >80%)
- Disk Space (alert >85%)
- Network Traffic

#### Application Metrics
- Jenkins build success rate
- SonarQube analysis duration
- Python app response time
- Docker container status

#### Dashboard URLs
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090
- CloudWatch: AWS Console

### Alert Configuration

#### Prometheus Alerts
```yaml
# Example alert rule
groups:
- name: instance
  rules:
  - alert: InstanceDown
    expr: up{job="node"} == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Instance {{ $labels.instance }} down"
```

#### CloudWatch Alarms
- CPUUtilization > 70% for 5 minutes
- StatusCheckFailed for any instance
- FreeStorageSpace < 20%

## Backup & Recovery

### Terraform State Backup
- Automated through S3 versioning
- Manual backup command:
```bash
aws s3 cp s3://tf-state-554930853385-devops-project/terraform.tfstate terraform.tfstate.backup
```

### Docker Volumes Backup
```bash
# Backup Jenkins data
docker run --rm --volumes-from jenkins -v $(pwd):/backup ubuntu tar cvf /backup/jenkins-backup.tar /var/jenkins_home

# Backup SonarQube data
docker run --rm --volumes-from sonarqube -v $(pwd):/backup ubuntu tar cvf /backup/sonarqube-backup.tar /opt/sonarqube/data
```

### Database Backup
```bash
# Backup SonarQube PostgreSQL
docker exec sonar-db pg_dump -U sonar sonar > sonarqube-db-backup.sql
```

### Recovery Procedures

#### Full Infrastructure Recovery
1. Restore Terraform state from S3
2. Run `terraform apply` to recreate infrastructure
3. Restore Docker volumes from backups
4. Restore databases from backups

#### Partial Service Recovery
```bash
# Restart individual containers
docker-compose -f /home/devops/apps/docker/docker-compose.yml restart [service]

# View logs for troubleshooting
docker logs [container_name]
```

## Troubleshooting

### Common Issues and Solutions

#### SSH Connectivity Issues
```bash
# Test bastion connectivity
ssh -v -i ~/.ssh/devopsproj devops@13.61.153.223

# Test app server connectivity through bastion
ssh -v -i ~/.ssh/devopsproj -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/devopsproj devops@13.61.153.223" devops@10.0.2.168

# Check SSH service status on instances
systemctl status ssh
```

#### Docker Issues
```bash
# Check Docker service status
systemctl status docker

# Check container status
docker ps -a
docker logs [container_name]

# Restart Docker daemon
sudo systemctl restart docker
```

#### Network Issues
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids sg-06b8a82e8d1fccc87 sg-0e6583775e0a2522b

# Test network connectivity
telnet 13.61.153.223 22
ping 10.0.2.168
```

#### Jenkins Pipeline Issues
```bash
# Check Jenkins logs
docker logs jenkins

# Check pipeline console output
# Accessed through Jenkins web UI
```

### Log Files Location

#### System Logs
- `/var/log/syslog` - System messages
- `/var/log/auth.log` - Authentication logs
- `/var/log/ufw.log` - Firewall logs

#### Application Logs
- Jenkins: `/var/jenkins_home/logs/`
- Docker: `docker logs [container_name]`
- Nginx: `/var/log/nginx/`

### Performance Troubleshooting

#### CPU/Memory Issues
```bash
# Check system resources
top
htop
free -h

# Check process resource usage
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head
```

#### Disk Issues
```bash
# Check disk space
df -h

# Check large files
du -sh /home/devops/apps/*
du -sh /var/lib/docker/volumes/*
```

## Maintenance Procedures

### Regular Maintenance Tasks

#### Weekly Tasks
1. Check and apply security updates
```bash
sudo apt update
sudo apt upgrade
```
2. Rotate logs and clean up old files
3. Verify backup integrity
4. Review monitoring alerts and metrics

#### Monthly Tasks
1. Review and update IAM policies
2. Rotate SSH keys and credentials
3. Review security group rules
4. Cost optimization review

### Update Procedures

#### Docker Container Updates
```bash
# Pull latest images and recreate containers
cd /home/devops/apps/docker
docker-compose pull
docker-compose up -d
```

#### Infrastructure Updates
```bash
# Update Terraform configurations
terraform plan
terraform apply
```

#### Application Updates
- Pushed through CI/CD pipeline
- Manual deployment if pipeline unavailable:
```bash
ansible-playbook ansible/deploy-app.yml --extra-vars "app_version=[version]"
```

### Capacity Planning

#### Monitoring Indicators
- CPU > 70% sustained → Consider larger instance
- Memory > 80% sustained → Consider larger instance
- Disk > 85% usage → Clean up or expand storage

#### Scaling Considerations
- Vertical scaling: Upgrade instance types
- Horizontal scaling: Add more app servers
- Load balancer: Add ALB/ELB for multiple instances

## Security Procedures

### Regular Security Tasks

#### Security Scanning
```bash
# Scan for vulnerabilities
docker scan [image_name]
trivy image [image_name]
```

#### Access Review
- Monthly review of IAM users and policies
- Quarterly SSH key rotation
- Regular review of security group rules

#### Audit Log Review
```bash
# Review authentication attempts
grep "Failed password" /var/log/auth.log
grep "Accepted password" /var/log/auth.log

# Review sudo commands
grep sudo /var/log/auth.log
```

### Incident Response

#### Security Incident Procedure
1. **Identify**: Detect and confirm incident
2. **Contain**: Isolate affected systems
3. **Eradicate**: Remove threat and vulnerabilities
4. **Recover**: Restore systems and services
5. **Learn**: Document lessons and improve

#### Contact Information
- AWS Support: https://aws.amazon.com/contact-us/
- Security Team: [Your security contact]

### Compliance Checklist

- [ ] No secrets in version control
- [ ] SSH key authentication only
- [ ] Regular security updates applied
- [ ] Backup procedures tested
- [ ] Access reviews completed
- [ ] Monitoring and alerting active

## Appendix

### Useful Commands

#### Docker Management
```bash
# View running containers
docker ps

# View container logs
docker logs [container_name]

# Execute command in container
docker exec -it [container_name] /bin/bash

# Restart containers
docker-compose -f /home/devops/apps/docker/docker-compose.yml restart
```

#### System Management
```bash
# Check system status
systemctl status docker jenkins nginx

# View disk usage
df -h /home /var

# Check memory usage
free -h

# Monitor real-time system metrics
htop
```

### Emergency Procedures

#### System Down Recovery
1. Check CloudWatch for instance status
2. SSH to instance to investigate
3. Restart Docker service if needed
4. Restart containers if needed
5. Restart instance as last resort

#### Data Loss Recovery
1. Identify latest good backup
2. Restore from backup procedures
3. Verify data integrity
4. Document incident and root cause

### Contact Information

#### AWS Support
- AWS Support Center: https://aws.amazon.com/contact-us/
- Region: eu-north-1

