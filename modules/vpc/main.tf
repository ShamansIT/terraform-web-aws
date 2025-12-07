# Discover available AZs inside region
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${lookup(var.tags, "Project", "terraform")}-vpc"
    }
  )
}

# Public subnets in first AZs
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name        = "${lookup(var.tags, "Project", "terraform")}-public-${count.index + 1}"
      Tier        = "public"
      AZ          = data.aws_availability_zones.available.names[count.index]
    }
  )
}

# Private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name        = "${lookup(var.tags, "Project", "terraform")}-private-${count.index + 1}"
      Tier        = "private"
      AZ          = data.aws_availability_zones.available.names[count.index]
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${lookup(var.tags, "Project", "terraform")}-igw"
    }
  )
}

# Public route table with default route to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  # Default route to Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${lookup(var.tags, "Project", "terraform")}-public-rt"
    }
  )
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
