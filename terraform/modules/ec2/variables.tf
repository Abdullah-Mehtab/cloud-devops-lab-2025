# --------------------------
# MODULE: EC2 VARIABLES
# --------------------------
# Purpose: Define all input variables for the EC2 module.
# Reasoning: Variables allow the module to be dynamic and reusable across different projects or environments.
# Each variable explains its purpose, type, source, and where it will be used.

# --------------------------
# VARIABLE: project_name
# --------------------------
variable "project_name" {
  description = "Project name for tagging"
  type        = string
  # Reasoning: Used for consistent naming of resources (EC2 instances, tags)
  # Where used: tags block in bastion and app_server EC2 resources
}

# --------------------------
# VARIABLE: instance_type
# --------------------------
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  # Reasoning: Defines the size/spec of the EC2 instances (CPU/RAM)
  # Where used: instance_type argument in aws_instance.bastion and aws_instance.app_server
  # Source: Passed from main.tf or terraform.tfvars
}

# --------------------------
# VARIABLE: public_subnet_id
# --------------------------
variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
  # Reasoning: Determines which public subnet the bastion host will launch in
  # Where used: subnet_id argument in aws_instance.bastion
  # Source: Output from VPC module
}

# --------------------------
# VARIABLE: private_subnet_id
# --------------------------
variable "private_subnet_id" {
  description = "Private subnet ID"
  type        = string
  # Reasoning: Determines which private subnet the application server will launch in
  # Where used: subnet_id argument in aws_instance.app_server
  # Source: Output from VPC module
}

# --------------------------
# VARIABLE: bastion_sg_id
# --------------------------
variable "bastion_sg_id" {
  description = "Bastion security group ID"
  type        = string
  # Reasoning: Security group to control inbound/outbound traffic for bastion host
  # Where used: vpc_security_group_ids argument in aws_instance.bastion
  # Source: Output from Security module
}

# --------------------------
# VARIABLE: app_server_sg_id
# --------------------------
variable "app_server_sg_id" {
  description = "Application server security group ID"
  type        = string
  # Reasoning: Security group to control traffic for app server EC2
  # Where used: vpc_security_group_ids argument in aws_instance.app_server
  # Source: Output from Security module
}

# --------------------------
# VARIABLE: key_name
# --------------------------
variable "key_name" {
  description = "SSH key name"
  type        = string
  # Reasoning: Allows EC2 instances to be accessed via SSH using this key
  # Where used: key_name argument in both aws_instance.bastion and aws_instance.app_server
  # Source: Output from Security module (imported SSH key)
}

# --------------------------
# VARIABLE: iam_instance_profile_name
# --------------------------
variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
  # Reasoning: Allows EC2 instances to assume IAM role for S3 and CloudWatch access
  # Where used: iam_instance_profile argument in both aws_instance resources
  # Source: Output from Security module
}
