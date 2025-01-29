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

# ASG Module

# Launch Template (defines EC2 instance configuration)
resource "aws_launch_template" "dev" {
  name_prefix   = "dev-lt"  # Unique name
  image_id      = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"  # Free-tier eligible
  key_name      = "your-key-pair"  # Replace with your EC2 key pair name

  # User data script (optional: install a web server)
  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
  EOF
  )

  # Tag instances with "env: dev"
  tag_specifications {
    resource_type = "instance"
    tags = { env = "dev" }  # Required by your project
  }
}

# Auto Scaling Group (manages EC2 instances)
resource "aws_autoscaling_group" "dev" {
  name                = "dev-asg"
  vpc_zone_identifier = var.private_subnet_ids  # Launch in private subnets
  desired_capacity    = 2  # Maintain 2 instances
  max_size            = 4  # Scale up to 4 under load
  min_size            = 1  # Never go below 1

  # Use the launch template
  launch_template {
    id      = aws_launch_template.dev.id
    version = "$Latest"  # Always use the latest version
  }

  # Tag ASG resources
  tag {
    key                 = "env"
    value               = "dev"
    propagate_at_launch = true  # Apply tag to all instances
  }
}