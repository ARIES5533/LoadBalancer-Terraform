# ########################################################################
# Provider Configuration for AWS
provider "aws" {
  region     = ""            # Specify the AWS region
  access_key = ""            # AWS access key
  secret_key = ""            # AWS secret key
}

# Create Virtual Private Cloud (VPC)
resource "aws_vpc" "ARIES_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ARIES-VPC"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "ARIES_igw" {
  vpc_id = aws_vpc.ARIES_vpc.id

  tags = {
    Name = "ARIES-IGW"
  }
}

# Create Public Subnet
resource "aws_subnet" "ARIES_public_subnet" {
  vpc_id                  = aws_vpc.ARIES_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ARIES-public-Subnet"
  }
}

# Attach Internet Gateway to Public Subnet
resource "aws_route_table" "ARIES_public_route_table" {
  vpc_id = aws_vpc.ARIES_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ARIES_igw.id
  }

  tags = {
    Name = "ARIES-Public-Route-Table"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "ARIES_public_route_association" {
  subnet_id      = aws_subnet.ARIES_public_subnet.id
  route_table_id = aws_route_table.ARIES_public_route_table.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "ARIES_nat_eip" {

}

# Create NAT Gateway
resource "aws_nat_gateway" "ARIES_nat_gateway" {
  allocation_id = aws_eip.ARIES_nat_eip.id
  subnet_id     = aws_subnet.ARIES_private_subnet.id

  tags = {
    Name = "Seamless-NAT-Gateway"
  }
}

# Create Private Subnet
resource "aws_subnet" "ARIES_private_subnet" {
  vpc_id            = aws_vpc.ARIES_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  # map_public_ip_on_launch = true

  tags = {
    Name = "ARIES-private-Subnet"
  }
}

# Create Security Group for ARIES ALB
resource "aws_security_group" "ARIES_security_group" {
  name        = "ARIES-Security-Group"
  description = "Security group for ARIES ALB"

  vpc_id = aws_vpc.ARIES_vpc.id

  # Define ingress and egress rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Target Group
resource "aws_lb_target_group" "ARIES_tg" {
  name        = "ARIES-tg"
  target_type = "instance"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.ARIES_vpc.id

  # Health check configuration
  health_check {
    path                = "/index.html"
    port                = 443
    protocol            = "HTTPS"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

# Create AWS Load Balancer
resource "aws_lb" "ARIES_alb" {
  name                       = "ARIES-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.ARIES_security_group.id]
  subnets                    = [aws_subnet.ARIES_private_subnet.id, aws_subnet.ARIES_public_subnet.id]
  enable_deletion_protection = false

  tags = {
    Name = "lol"
  }
}

# Create a listener on port 80 with redirect action
resource "aws_lb_listener" "ARIES_http_lister" {
  load_balancer_arn = aws_lb.ARIES_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
    }
  }
}

# Create a listener on port 443 with forward action
resource "aws_lb_listener" "ARIES_https_lister" {
  load_balancer_arn = aws_lb.ARIES_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = ""

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ARIES_tg.arn
  }
}

##3##########################################################################