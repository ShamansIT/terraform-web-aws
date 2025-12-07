# main.tf
#
# Root Terraform configuration file. Network, compute, and load balancer 
# resources will be added in later stages


# ***************************************************
# Locals: common tags
# ***************************************************

locals {
  environment = "lab"
  project     = "terraform-web-aws"
  owner       = "Serhii"

  common_tags = {
    Environment = local.environment
    Project     = local.project
    Owner       = local.owner
  }
}

# ***************************************************
# AMI for web instances
# ***************************************************

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
# VPC + networking (module)
# ***************************************************

module "vpc" {
  source = "./modules/vpc"

  cidr_block           = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

  tags = local.common_tags
}

# ***************************************************
# Security Groups (shared security layer)
# ***************************************************

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP from the internet to the ALB"
  vpc_id      = module.vpc.vpc_id

  # HTTP from anywhere to ALB on port 80
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress so ALB can reach targets and perform health checks
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name      = "alb-sg"
      Component = "load-balancer"
    }
  )
}

# Web Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP from ALB and optional SSH from a trusted IP"
  vpc_id      = module.vpc.vpc_id

  # HTTP only from ALB SG - web nodes are not public on port 80
  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH from trusted IP for management
  ingress {
    description = "SSH from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # Outbound allowed for updates, package installs, etc.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name      = "web-sg"
      Component = "web"
    }
  )
}

# ***************************************************
# Web EC2 cluster (module)
# ***************************************************

module "web" {
  source = "./modules/web"

  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.web_sg.id]
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  user_data          = file("${path.module}/userdata-web.sh")

  tags = local.common_tags
}

# ***************************************************
# Application Load Balancer (module)
# ***************************************************

module "alb" {
  source = "./modules/alb"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.alb_sg.id]

  target_instance_ids = module.web.instance_ids
  target_port         = 80

  tags = local.common_tags
}
