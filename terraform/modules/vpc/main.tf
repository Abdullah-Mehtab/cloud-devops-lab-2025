# --------------------------
# MODULE: VPC
# --------------------------
# This module creates all networking components for our project:
# - VPC (virtual network)
# - Public and private subnets
# - Internet Gateway (IGW) for public access
# - NAT Gateway for private subnet internet access
# - Route tables and associations
# Reasoning: Modularizing VPC setup allows reusability across projects/environments

# --------------------------
# RESOURCE: aws_vpc.main
# --------------------------
resource "aws_vpc" "main" {
  # VARIABLE: cidr_block
  # Assign VPC IP range from variable defined in variables.tf or tfvars
  # Usage: Creates the network IP space for all subnets/resources
  cidr_block = var.vpc_cidr

  # Enable DNS resolution inside VPC
  enable_dns_support = true

  # Enable DNS hostnames for instances (like EC2) to have private DNS
  enable_dns_hostnames = true

  # TAGS: for identifying resources in AWS console
  tags = {
    Name = "${var.project_name}-vpc" # Example: "devops-project-vpc"
  }
}

# --------------------------
# RESOURCE: aws_subnet.public
# --------------------------
resource "aws_subnet" "public" {
  # VPC ID where subnet is created
  vpc_id = aws_vpc.main.id

  # CIDR block for public subnet
  cidr_block = var.public_subnet_cidr

  # Availability zone for subnet placement (using aws_region variable)
  availability_zone = "${var.aws_region}a"

  # Map public IPs automatically on launch for public access
  map_public_ip_on_launch = true

  # TAGS: identify public subnet
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# --------------------------
# RESOURCE: aws_subnet.private
# --------------------------
resource "aws_subnet" "private" {
  # VPC ID where subnet is created
  vpc_id = aws_vpc.main.id

  # CIDR block for private subnet
  cidr_block = var.private_subnet_cidr

  # Availability zone (same as public for simplicity)
  availability_zone = "${var.aws_region}a"

  # TAGS: identify private subnet
  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# --------------------------
# RESOURCE: aws_internet_gateway.main
# --------------------------
resource "aws_internet_gateway" "main" {
  # Attach IGW to the VPC for internet access
  vpc_id = aws_vpc.main.id

  # TAGS: identify IGW
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --------------------------
# RESOURCE: aws_eip.nat
# --------------------------
resource "aws_eip" "nat" {
  # Allocate Elastic IP for NAT Gateway
  domain = "vpc"

  # TAGS: identify NAT EIP
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# --------------------------
# RESOURCE: aws_nat_gateway.main
# --------------------------
resource "aws_nat_gateway" "main" {
  # Link NAT Gateway to the Elastic IP allocated above
  allocation_id = aws_eip.nat.id

  # Deploy NAT in the public subnet (so private subnet can route through it)
  subnet_id = aws_subnet.public.id

  # TAGS: identify NAT Gateway
  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  # DEPENDENCY: ensure NAT Gateway is created after Internet Gateway
  depends_on = [aws_internet_gateway.main]
}

# --------------------------
# RESOURCE: aws_route_table.public
# --------------------------
resource "aws_route_table" "public" {
  # VPC where route table belongs
  vpc_id = aws_vpc.main.id

  # ROUTE: send all internet traffic (0.0.0.0/0) via Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  # TAGS: identify public route table
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# --------------------------
# RESOURCE: aws_route_table.private
# --------------------------
resource "aws_route_table" "private" {
  # VPC where route table belongs
  vpc_id = aws_vpc.main.id

  # ROUTE: send all internet traffic via NAT Gateway
  # Private subnet uses NAT to access internet while remaining private
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  # TAGS: identify private route table
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# --------------------------
# RESOURCE: aws_route_table_association.public
# --------------------------
resource "aws_route_table_association" "public" {
  # Associate public subnet with public route table
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --------------------------
# RESOURCE: aws_route_table_association.private
# --------------------------
resource "aws_route_table_association" "private" {
  # Associate private subnet with private route table
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# -------------------------------------------------------
# SUMMARY / REASONING
# -------------------------------------------------------
# 1. VPC provides isolated network for all project resources.
# 2. Public subnet hosts Bastion or public-facing resources.
# 3. Private subnet hosts application servers, not directly accessible from Internet.
# 4. Internet Gateway allows public subnet to reach internet.
# 5. NAT Gateway allows private subnet instances to access internet safely.
# 6. Route tables define traffic flow: public->IGW, private->NAT.
# 7. Route table associations attach correct routing to subnets.
# 8. Tags make resources identifiable in AWS console for management and cost tracking.

# Route Table hota kya hai? 
# GPS for data-packets (map/direction guide)
# Public Subnet (GPS directs to main highway - internet)
# Private Subnet (GPS Direct you to local bridge (NAT) to reach highway indirectly)