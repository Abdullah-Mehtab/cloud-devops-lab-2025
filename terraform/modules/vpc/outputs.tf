# --------------------------
# MODULE: VPC OUTPUTS
# --------------------------
# This file defines the output values for the VPC module
# Outputs allow parent modules (main.tf) or other modules to access resources created here
# Purpose: Expose key IDs that other modules/resources depend on (e.g., EC2 module needs subnet IDs)

# --------------------------
# OUTPUT: vpc_id
# --------------------------
output "vpc_id" {
  # DESCRIPTION: Human-readable description of this output
  description = "VPC ID"

  # VALUE: The actual AWS resource ID returned by aws_vpc.main
  value       = aws_vpc.main.id
  # Reasoning: EC2, security groups, and route tables need the VPC ID to attach resources
  # Where used: Referenced in main.tf or other modules using module.vpc.vpc_id
}

# --------------------------
# OUTPUT: public_subnet_id
# --------------------------
output "public_subnet_id" {
  description = "Public subnet ID"

  # VALUE: AWS subnet ID of the public subnet
  value       = aws_subnet.public.id
  # Reasoning: EC2 instances or NAT Gateways deployed in public subnet require this ID
  # Where used: main.tf references module.vpc.public_subnet_id when creating bastion or NAT
}

# --------------------------
# OUTPUT: private_subnet_id
# --------------------------
output "private_subnet_id" {
  description = "Private subnet ID"

  # VALUE: AWS subnet ID of the private subnet
  value       = aws_subnet.private.id
  # Reasoning: EC2 instances or services in private subnet need this ID
  # Where used: main.tf references module.vpc.private_subnet_id when creating app servers
}
