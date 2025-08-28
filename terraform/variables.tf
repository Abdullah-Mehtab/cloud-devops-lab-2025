# --------------------------
# MODULE: VARIABLES
# --------------------------
# This file defines all reusable input variables for Terraform modules/resources
# Variables allow us to configure values without hardcoding them in the main.tf or modules
# They make the Terraform code modular, reusable, and easier to maintain

# --------------------------
# VARIABLE: aws_region
# --------------------------
variable "aws_region" {
  # DESCRIPTION: A human-readable description of what this variable is
  description = "AWS region"

  # TYPE: Specifies the type of value allowed for this variable
  # string = expects text value
  type = string

  # DEFAULT: If no value is passed when running Terraform, this value will be used
  default = "eu-north-1" # Stockholm region
  # Reasoning: Default ensures resources deploy in a specific region without needing extra input
  # Where used: This variable will be referenced in provider blocks or modules requiring region info
}

# --------------------------
# VARIABLE: vpc_cidr
# --------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC" # Human-friendly explanation
  type        = string               # Data type is string
  default     = "10.0.0.0/16"        # Default CIDR block for the VPC
  # Reasoning: CIDR defines the IP address range of the VPC
  # Where used: Passed to VPC module to create the virtual network
  # Why defined: Makes VPC IP range configurable without editing the module
}

# --------------------------
# VARIABLE: public_subnet_cidr
# --------------------------
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet" # Explains purpose
  type        = string                         # Must be string
  default     = "10.0.1.0/24"                  # Default IP range for public subnet
  # Reasoning: Public subnet hosts resources accessible from the internet (e.g., bastion)
  # Where used: Passed to VPC module or subnet creation resource
  # Why defined: Makes subnet configurable and avoids hardcoding
}

# --------------------------
# VARIABLE: private_subnet_cidr
# --------------------------
variable "private_subnet_cidr" {
  description = "CIDR block for private subnet" # Explanation
  type        = string                          # Must be string
  default     = "10.0.2.0/24"                   # Default IP range for private subnet
  # Reasoning: Private subnet hosts resources not directly exposed to internet (e.g., app server)
  # Where used: Passed to VPC module for creating private subnet
  # Why defined: Ensures flexibility and modularity
}

# --------------------------
# VARIABLE: instance_type
# --------------------------
variable "instance_type" {
  description = "EC2 instance type" # Explains what this variable configures
  type        = string              # Must be a string
  default     = "t3.micro"          # Default EC2 size (small, low-cost)
  # Reasoning: Defines hardware configuration (CPU, RAM) for EC2 instances
  # Where used: Passed to EC2 module when creating instances
  # Why defined: Makes instance type configurable without editing EC2 module directly
}
