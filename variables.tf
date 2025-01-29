variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for ASG"
  type        = list(string)
}

# Public Route Table- All traffic
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"  
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}
