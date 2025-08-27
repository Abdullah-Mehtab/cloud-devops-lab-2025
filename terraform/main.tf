# --------------------------
# MODULE: terraform block
# --------------------------

terraform {
  # REQUIRED TERRAFORM VERSION
  # Ensures Terraform version >= 1.0.0 is used.
  # Terraform uses this version check to avoid running incompatible code.
  required_version = ">= 1.0.0"

  # REQUIRED PROVIDERS
  # Specifies providers this configuration needs.
  # 'aws' provider allows Terraform to create/manage AWS resources.
  required_providers {
    aws = {
      # SOURCE: where Terraform fetches the provider from
      # 'hashicorp/aws' is the official AWS provider
      source  = "hashicorp/aws"

      # VERSION: ensures compatibility with Terraform code
      # "~> 5.0" allows any 5.x version but not 6.0
      version = "~> 5.0"
    }
  }

  # BACKEND CONFIGURATION
  # Tells Terraform where to store its state file
  # State file keeps track of all resources Terraform manages
  # Using S3 + DynamoDB enables safe collaboration and locking
  backend "s3" {
    # S3 BUCKET NAME: where Terraform state file will be stored
    # Must match the bucket we created manually before
    bucket         = "tf-state-554930853385-devops-project"

    # KEY: path to the state file inside the S3 bucket
    # Allows multiple projects in same bucket using different keys
    key            = "terraform.tfstate"

    # REGION: AWS region for S3 bucket and DynamoDB table
    # Must match actual AWS resources created
    region         = "eu-north-1"

    # DYNAMODB TABLE NAME: used for locking Terraform state
    # Prevents multiple users/processes from editing state simultaneously
    dynamodb_table = "terraform-state-lock"

    # ENCRYPT: ensures state file is encrypted at rest
    encrypt        = true
  }
}

# --------------------------
# MODULE: AWS PROVIDER
# --------------------------

provider "aws" {
  # VARIABLE: region
  # Which AWS region to use for all resources unless overridden
  region = var.aws_region

  # DEFAULT TAGS
  # Tags applied to all AWS resources created by this provider
  default_tags {
    tags = {
      Project     = "devops-internship" # identifies project
      Environment = "dev"               # environment type
      ManagedBy   = "terraform"         # indicates management tool
    }
  }
}

# --------------------------
# MODULE: locals block
# --------------------------

locals {
  # VARIABLE: project_name
  # Local variable for consistent naming convention across modules/resources
  # Example: used in VPC name, subnets, EC2 instance names, security groups, etc.
  project_name = "devops-project"
}

# --------------------------
# MODULE: VPC
# --------------------------

module "vpc" {
  source              = "./modules/vpc"  # path to VPC module
  project_name        = local.project_name  # variable for tagging and naming
  vpc_cidr            = var.vpc_cidr        # CIDR block for the VPC
  public_subnet_cidr  = var.public_subnet_cidr  # CIDR for public subnet
  private_subnet_cidr = var.private_subnet_cidr # CIDR for private subnet
  aws_region          = var.aws_region          # AWS region to deploy resources
}

# --------------------------
# MODULE: Security (Security Groups & Key Pair)
# --------------------------

module "security" {
  source       = "./modules/security"  # path to security module
  project_name = local.project_name     # used for naming/security group tags
  vpc_id       = module.vpc.vpc_id      # VPC ID from VPC module, used to attach security groups
}

# --------------------------
# MODULE: EC2 Instances (Bastion + App Server)
# --------------------------

module "ec2" {
  source                    = "./modules/ec2"           # path to EC2 module
  project_name              = local.project_name         # used for naming EC2 instances
  instance_type            = var.instance_type          # type of EC2 instances (t3.micro, etc.)
  public_subnet_id         = module.vpc.public_subnet_id  # ID of public subnet for bastion
  private_subnet_id        = module.vpc.private_subnet_id # ID of private subnet for app server
  bastion_sg_id           = module.security.bastion_sg_id  # security group for bastion host
  app_server_sg_id        = module.security.app_server_sg_id # security group for app server
  key_name                = module.security.key_name    # SSH key name to access EC2 instances
  iam_instance_profile_name = module.security.ec2_instance_profile_name # IAM instance profile for EC2 instances
}
