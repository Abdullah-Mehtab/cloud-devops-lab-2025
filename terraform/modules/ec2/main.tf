# --------------------------
# MODULE: EC2 INSTANCES
# --------------------------
# Purpose: Define EC2 instances for the project: a bastion host in the public subnet 
# and an application server in the private subnet.
# Reasoning: Separates EC2 provisioning into its own module for clarity, reusability, and modular architecture.

# --------------------------
# MODULE: BASTION HOST
# --------------------------
resource "aws_instance" "bastion" {
  # DESCRIPTION: Defines an EC2 instance for the bastion host
  # Reasoning: Bastion hosts provide a secure entry point into private network resources

  # VARIABLE: ami
  ami = data.aws_ami.ubuntu.id
  # Source: Fetched dynamically from the aws_ami data block below
  # Reasoning: Always uses the latest Ubuntu AMI for consistency and security

  # VARIABLE: instance_type
  instance_type = var.instance_type
  # Source: Passed from module input (main.tf / terraform.tfvars)
  # Reasoning: Defines the VM size (CPU/RAM); using "t3.micro" as default for cost-effective dev/test

  # VARIABLE: subnet_id
  subnet_id = var.public_subnet_id
  # Source: Passed from VPC module output
  # Reasoning: Bastion must be in a public subnet to allow SSH access from the internet

  # VARIABLE: vpc_security_group_ids
  vpc_security_group_ids = [var.bastion_sg_id]
  # Source: Security module output
  # Reasoning: Attach bastion SG to control traffic (SSH only allowed from trusted sources)

  # VARIABLE: key_name
  key_name = var.key_name
  # Source: Security module output
  # Reasoning: EC2 needs a key pair to allow SSH login

  # VARIABLE: iam_instance_profile
  iam_instance_profile = var.iam_instance_profile_name
  # Source: Security module output
  # Reasoning: Attach IAM role via instance profile for S3 and CloudWatch access

  # TAGS
  tags = {
    Name = "${var.project_name}-bastion"
    # Reasoning: Naming convention helps identify resources in AWS console
  }
}

# --------------------------
# MODULE: APPLICATION SERVER
# --------------------------
resource "aws_instance" "app_server" {
  # DESCRIPTION: Defines an EC2 instance for the application server
  # Reasoning: App server lives in private subnet; accessed only via bastion or internal network

  ami                    = data.aws_ami.ubuntu.id
  # Same as bastion, latest Ubuntu AMI

  instance_type          = var.instance_type
  # Same as bastion, instance size from input

  subnet_id              = var.private_subnet_id
  # Source: Passed from VPC module output
  # Reasoning: Private subnet ensures it's not exposed directly to the internet

  vpc_security_group_ids = [var.app_server_sg_id]
  # Source: Security module output
  # Reasoning: App server SG controls traffic; allows SSH only from bastion, HTTP from internet as required

  key_name               = var.key_name
  # Same SSH key as bastion for login

  # VARIABLE: iam_instance_profile
  iam_instance_profile = var.iam_instance_profile_name
  # Source: Security module output
  # Reasoning: Attach IAM role via instance profile for S3 and CloudWatch access

  tags = {
    Name = "${var.project_name}-app-server"
    # Naming convention for identification
  }
}

# --------------------------
# MODULE: DATA SOURCE FOR AMI
# --------------------------
data "aws_ami" "ubuntu" {
  # DESCRIPTION: Retrieves the latest Ubuntu AMI dynamically
  # Reasoning: Ensures EC2 instances always use a secure and up-to-date OS image

  most_recent = true
  # Always fetch the latest available image

  owners = ["099720109477"]
  # Canonical account ID for official Ubuntu AMIs
  # Ensures the image is legitimate and trusted

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    # Pattern matches Ubuntu 22.04 HVM SSD images
    # Reasoning: Ensures the right Ubuntu version is selected
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
    # Reasoning: Selects only hardware virtualized images compatible with instance types
  }
}
