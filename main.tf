# main.tf
#
# Root Terraform configuration file. Network, compute, and load balancer 
# resources will be added in later stages


# ***************************************************
# Data sources
# ***************************************************

# Get list Availability Zones in chosen region
data "aws_availability_zones" "available" {
  state = "available"
}


# ***************************************************
# VPC
# ***************************************************

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "terraform-web-vpc"
    Project     = "terraform-web-aws"
    Environment = "lab"
  }
}


# ***************************************************
# Public subnets (for ALB and potential publicfacing resources)
# ***************************************************

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-a"
    Tier        = "public"
    Environment = "lab"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-b"
    Tier        = "public"
    Environment = "lab"
  }
}


# ***************************************************
# Private subnets (reserved for non-public workloads)
# ***************************************************

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "private-a"
    Tier        = "private"
    Environment = "lab"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "private-b"
    Tier        = "private"
    Environment = "lab"
  }
}


# ***************************************************
# Internet Gateway
# ***************************************************

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "terraform-web-igw"
    Environment = "lab"
  }
}


# ***************************************************
# Public route table
# ***************************************************

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Correct default route
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "public-rt"
    Environment = "lab"
  }
}


# ***************************************************
# Route table associations for public subnets
# ***************************************************

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}