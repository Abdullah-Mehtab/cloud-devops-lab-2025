# --------------------------
# MODULE: ROOT OUTPUTS
# --------------------------
# Purpose: Define outputs at the root module level.
# Reasoning: Root outputs aggregate important information from sub-modules
# (VPC, EC2) for easy access after Terraform apply.
# This allows other tools, scripts, or users to know key infrastructure details
# without digging into individual module internals.

# --------------------------
# OUTPUT: vpc_id
# --------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
  # Reasoning: Exposes the unique ID of the VPC created by the VPC module
  # Source: module.vpc outputs.vpc_id
  # Usage: Can be used by other modules, scripts, or for debugging
}

# --------------------------
# OUTPUT: bastion_public_ip
# --------------------------
output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = module.ec2.bastion_public_ip
  # Reasoning: Exposes the public IP of the bastion host EC2 from EC2 module
  # Source: module.ec2 outputs.bastion_public_ip
  # Usage: Needed to SSH into the bastion host or for automated provisioning
}

# --------------------------
# OUTPUT: app_server_private_ip
# --------------------------
output "app_server_private_ip" {
  description = "Application server private IP"
  value       = module.ec2.app_server_private_ip
  # Reasoning: Exposes private IP of application server EC2
  # Source: module.ec2 outputs.app_server_private_ip
  # Usage: Useful for connecting to app server internally via bastion or scripts
}

# --------------------------
# OUTPUT: public_subnet_id
# --------------------------
output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.vpc.public_subnet_id
  # Reasoning: Exposes public subnet ID created in VPC module
  # Source: module.vpc outputs.public_subnet_id
  # Usage: Used by EC2 module to place bastion host in the public subnet
}

# --------------------------
# OUTPUT: private_subnet_id
# --------------------------
output "private_subnet_id" {
  description = "Private subnet ID"
  value       = module.vpc.private_subnet_id
  # Reasoning: Exposes private subnet ID created in VPC module
  # Source: module.vpc outputs.private_subnet_id
  # Usage: Used by EC2 module to place application server in private subnet
}
