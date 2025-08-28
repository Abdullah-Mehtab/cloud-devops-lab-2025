# --------------------------
# MODULE: SECURITY
# --------------------------
# Purpose: Create security-related resources:
# - Import existing SSH key for EC2 access
# - Security group for bastion host
# - Security group for application server
# Reasoning: Security groups control inbound/outbound traffic. Using a separate module
# keeps security configuration modular and reusable.

# --------------------------
# RESOURCE: aws_key_pair.devops_key
# --------------------------
resource "aws_key_pair" "devops_key" {
  # KEY NAME: AWS identifier for this key
  key_name = "devops-proj-key"

  # PUBLIC KEY: Path to local public SSH key
  # Reasoning: This allows Terraform to import an existing key instead of creating a new one
  # Usage: EC2 instances launched with this key can be accessed via SSH
  public_key = file("~/.ssh/devopsproj.pub")

  # TAGS: For easy identification in AWS console
  tags = {
    Name = "${var.project_name}-ssh-key"
  }
}

# --------------------------
# RESOURCE: aws_security_group.bastion
# --------------------------
resource "aws_security_group" "bastion" {
  # Name of security group in AWS
  name = "${var.project_name}-bastion-sg"

  # Description for clarity
  description = "Security group for bastion host"

  # Attach SG to specific VPC
  vpc_id = var.vpc_id

  # --------------------------
  # INGRESS RULE: SSH from anywhere
  # --------------------------
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all IPs (could restrict later)
    # Reasoning: Bastion host must be reachable via SSH from your local machine
  }

  # --------------------------
  # EGRESS RULE: Allow all outbound traffic
  # --------------------------
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound to anywhere
    # Reasoning: Bastion may need to connect to app servers or internet
  }

  # TAGS: identify in AWS console
  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

# --------------------------
# RESOURCE: aws_security_group.app_server
# --------------------------
# --------------------------
# UPDATE ADDED: Enhanced application server security group with dynamic app ports
# The following resource was added/updated to:
# - keep SSH limited to bastion SG
# - expose Flask HTTP port 8000 publicly
# - allow other application ports only from bastion via a dynamic block using var.app_ports
# --------------------------
# Security group for application server
resource "aws_security_group" "app_server" {
  name        = "${var.project_name}-app-server-sg"
  description = "Security group for application server"
  vpc_id      = var.vpc_id

  # SSH from bastion only
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # HTTP for Flask app (public)
  ingress {
    description = "HTTP for Flask app"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add all other application ports (accessible only from bastion)
  dynamic "ingress" {
    for_each = var.app_ports
    content {
      description     = "Access for ${ingress.key}"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.bastion.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-server-sg"
  }
}
# --------------------------
# IAM Resources
# --------------------------

# IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# IAM policy for S3 and CloudWatch access
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.project_name}-ec2-policy"
  description = "Policy for EC2 to access S3 and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
          "cloudwatch:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# --------------------------
# SSM Parameters
# --------------------------

# SSM parameters for Jenkins credentials
resource "random_password" "jenkins_password" {
  length  = 16
  special = true
}

resource "aws_ssm_parameter" "jenkins_user" {
  name  = "/jenkins/user"
  type  = "String"
  value = "admin"
}

resource "aws_ssm_parameter" "jenkins_password" {
  name  = "/jenkins/password"
  type  = "SecureString"
  value = random_password.jenkins_password.result
}
