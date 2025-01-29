# Fetch available AWS Availability Zones (AZs)
data "aws_availability_zones" "available" {}

## **VPC Module
# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr  # Defined in variables.tf
  enable_dns_support   = true          
  enable_dns_hostnames = true
  tags = { Name = "dev-vpc" }
}

# Create Public subnet
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-${count.index + 1}" }
}

# Create Private subnet
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "private-subnet-${count.index + 1}" }
}

# Internet Gateway
# Internet Gateway (for public subnets)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "dev-igw" }
}

