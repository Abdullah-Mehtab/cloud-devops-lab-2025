# --------------------------
# MODULE: VPC VARIABLES
# --------------------------
# This file defines input variables specifically for the VPC module
# Purpose: Makes the VPC module configurable, reusable, and decoupled from hardcoded values

# --------------------------
# VARIABLE: project_name
# --------------------------
variable "project_name" {
  # DESCRIPTION: Human-readable project name used for tagging AWS resources
  description = "Project name for tagging"
  
  # TYPE: string
  # Reasoning: Tags help identify and organize resources in AWS console and billing
  # Source: Passed from main.tf when module is called
  # Usage: Used in resource tags like Name = "${var.project_name}-vpc"
}

# --------------------------
# VARIABLE: vpc_cidr
# --------------------------
variable "vpc_cidr" {
  # DESCRIPTION: IP address range for the VPC
  description = "CIDR block for VPC"
  
  # TYPE: string
  # Reasoning: Defines network IP space for the VPC; essential for subnet allocation
  # Source: Passed from main.tf or terraform.tfvars
  # Usage: Used in aws_vpc resource as cidr_block
}

# --------------------------
# VARIABLE: public_subnet_cidr
# --------------------------
variable "public_subnet_cidr" {
  # DESCRIPTION: IP address range for the public subnet
  description = "CIDR block for public subnet"
  
  # TYPE: string
  # Reasoning: Public subnet hosts resources that need internet access (e.g., bastion host)
  # Source: Passed from main.tf or terraform.tfvars
  # Usage: Used in aws_subnet.public resource as cidr_block
}

# --------------------------
# VARIABLE: private_subnet_cidr
# --------------------------
variable "private_subnet_cidr" {
  # DESCRIPTION: IP address range for the private subnet
  description = "CIDR block for private subnet"
  
  # TYPE: string
  # Reasoning: Private subnet hosts resources that should not be publicly accessible (e.g., app servers)
  # Source: Passed from main.tf or terraform.tfvars
  # Usage: Used in aws_subnet.private resource as cidr_block
}

# --------------------------
# VARIABLE: aws_region
# --------------------------
variable "aws_region" {
  # DESCRIPTION: AWS region where all VPC resources will be created
  description = "AWS region"
  
  # TYPE: string
  # Reasoning: Ensures resources are deployed in a specific region
  # Source: Passed from main.tf or terraform.tfvars
  # Usage: Used for subnet availability_zone, and other region-specific resources
}
