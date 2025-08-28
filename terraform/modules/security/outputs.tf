# --------------------------
# MODULE: SECURITY OUTPUTS
# --------------------------
# Purpose: Expose important resource identifiers from the security module
# Reasoning: Other modules (like EC2 module) or main.tf need these IDs to attach resources
# without hardcoding values. Outputs enable module chaining and reusability.

# --------------------------
# OUTPUT: bastion_sg_id
# --------------------------
output "bastion_sg_id" {
  # DESCRIPTION: Human-readable explanation of this output
  description = "Bastion security group ID"

  # VALUE: References the ID of the bastion security group created in this module
  value = aws_security_group.bastion.id
  # Reasoning: EC2 instances that act as bastion hosts need this SG attached
  # Where used: main.tf or EC2 module uses module.security.bastion_sg_id
}

# --------------------------
# OUTPUT: app_server_sg_id
# --------------------------
output "app_server_sg_id" {
  description = "Application server security group ID"

  # VALUE: References the ID of the application server security group
  value = aws_security_group.app_server.id
  # Reasoning: EC2 instances for the app server must attach this SG to control traffic
  # Where used: main.tf or EC2 module uses module.security.app_server_sg_id
}

# --------------------------
# OUTPUT: key_name
# --------------------------
output "key_name" {
  description = "SSH key name"

  # VALUE: Returns the key name of the imported AWS key pair
  value = aws_key_pair.devops_key.key_name
  # Reasoning: EC2 instances need the key name to attach for SSH login
  # Where used: main.tf or EC2 module uses module.security.key_name when creating instances
}

# --------------------------
# OUTPUT: ec2_instance_profile_name
# --------------------------
output "ec2_instance_profile_name" {
  description = "IAM instance profile name"
  value       = aws_iam_instance_profile.ec2_profile.name
  # Reasoning: EC2 instances need this profile to assume the IAM role
  # Where used: EC2 module uses this to attach IAM role to instances
}