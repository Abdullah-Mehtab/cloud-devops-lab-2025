# --------------------------
# MODULE: SECURITY VARIABLES
# --------------------------
# This file defines input variables specifically for the security module
# Purpose: Makes the security module configurable and reusable without hardcoding values

# --------------------------
# VARIABLE: project_name
# --------------------------
variable "project_name" {
  # DESCRIPTION: Human-readable project name used for tagging AWS resources
  description = "Project name for tagging"

  # TYPE: string
  # Reasoning: Tags help identify and organize resources in AWS console and billing
  # Source: Passed from main.tf when module is called
  # Usage: Used in resource tags and names like "${var.project_name}-bastion-sg"
}

# --------------------------
# VARIABLE: vpc_id
# --------------------------
variable "vpc_id" {
  # DESCRIPTION: The AWS VPC ID where security resources (SGs) will be created
  description = "VPC ID"

  # TYPE: string
  # Reasoning: Security groups must belong to a specific VPC; can't be created outside
  # Source: Passed from VPC module outputs via main.tf (module.vpc.vpc_id)
  # Usage: Used in aws_security_group.bastion and aws_security_group.app_server resources
}

variable "app_ports" {
  description = "Map of application names to port numbers that should be accessible from the bastion"
  type        = map(number)
  default = {
    nginx       = 80
    jenkins     = 8080
    sonarqube   = 9001  # Note: This matches your docker-compose mapping
    grafana     = 3000
    prometheus  = 9090
  }
}