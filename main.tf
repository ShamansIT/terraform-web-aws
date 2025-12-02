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
# AMI for web instances
# ***************************************************

# Use Amazon Linux 2 AMI in selected region.
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
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


# ***************************************************
# Security Groups
# ***************************************************

# Security Group for App Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP from internet to ALB"
  vpc_id      = aws_vpc.main.id

  # Ingress: allow HTTP from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb-sg"
    Component   = "load-balancer"
    Environment = "lab"
  }
}

# Security Group for web EC2 instances
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP from ALB and optional SSH from a trusted IP"
  vpc_id      = aws_vpc.main.id

  # Ingress: allow HTTP from ALB security group only
  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Ingress: allow SSH from trusted IP only
  ingress {
    description = "SSH from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # Egress: allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-sg"
    Component   = "web"
    Environment = "lab"
  }
}


# ***************************************************
# EC2 Web Cluster - 2 instances across 2 AZs
# ***************************************************

resource "aws_instance" "web_a" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("${path.module}/userdata-web.sh")

  associate_public_ip_address = true

  tags = {
    Name        = "web-a"
    Role        = "web"
    Environment = "lab"
    AZ          = data.aws_availability_zones.available.names[0]
  }
}

resource "aws_instance" "web_b" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("${path.module}/userdata-web.sh")

  associate_public_ip_address = true

  tags = {
    Name        = "web-b"
    Role        = "web"
    Environment = "lab"
    AZ          = data.aws_availability_zones.available.names[1]
  }
}

# ***************************************************
# Application Load Balancer
# ***************************************************

resource "aws_lb" "web_alb" {
  name               = "web-alb"
  load_balancer_type = "application"
  internal           = false

  # Public subnets for ALB
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name        = "web-alb"
    Component   = "load-balancer"
    Environment = "lab"
  }
}

# ***************************************************
# Target Group for web instances
# ***************************************************

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "web-tg"
    Component   = "web"
    Environment = "lab"
  }
}

# ***************************************************
# Attach web instances to Target Group
# ***************************************************

resource "aws_lb_target_group_attachment" "web_a_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_b_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_b.id
  port             = 80
}

# ***************************************************
# ALB Listener (HTTP :80)
# ***************************************************

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
