# --------------------------
# MODULE: EC2 OUTPUTS
# --------------------------
# Purpose: Define output values for the EC2 module.
# Reasoning: Outputs allow other modules or root module to reference key information
# such as IP addresses, instance IDs, etc., without hardcoding them.
# They are useful for connecting modules together and for inspection after Terraform apply.

# --------------------------
# OUTPUT: bastion_public_ip
# --------------------------
output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = aws_instance.bastion.public_ip
  # Reasoning: Provides the public IP of the bastion host for SSH access
  # Source: aws_instance.bastion resource in this module
  # Usage: Can be used by other modules, scripts, or outputs in main.tf
}

# --------------------------
# OUTPUT: app_server_private_ip
# --------------------------
output "app_server_private_ip" {
  description = "Application server private IP"
  value       = aws_instance.app_server.private_ip
  # Reasoning: Gives the private IP of the app server, since it lives in a private subnet
  # Source: aws_instance.app_server resource in this module
  # Usage: Can be used by bastion host, scripts, or Ansible for configuration
}

# --------------------------
# OUTPUT: bastion_instance_id
# --------------------------
output "bastion_instance_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
  # Reasoning: Unique AWS identifier for the bastion EC2 instance
  # Source: aws_instance.bastion resource
  # Usage: Useful for automation, tagging, or referencing the instance elsewhere
}

# --------------------------
# OUTPUT: app_server_instance_id
# --------------------------
output "app_server_instance_id" {
  description = "Application server instance ID"
  value       = aws_instance.app_server.id
  # Reasoning: Unique AWS identifier for the private app server instance
  # Source: aws_instance.app_server resource
  # Usage: Useful for automation, monitoring, or referencing in other modules or scripts
}
