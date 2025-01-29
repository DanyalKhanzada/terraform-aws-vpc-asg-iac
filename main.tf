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
