terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.1"
    }
  }
}

provider "aws" {
  region = var.lab6_region
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "Allow EC2 to access S3"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::${var.lab6_bucket_name}", "arn:aws:s3:::${var.lab6_bucket_name}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

// create a bucket in S3
resource "aws_s3_bucket" "lab6_bucket" {
  bucket = var.lab6_bucket_name
  tags = {
    Env = "lab"
  }
}

// create a ssh key pair
resource "aws_key_pair" "lab6_key" {
  key_name   = "lab6-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

// VPC and Subnet
resource "aws_vpc" "lab6_vpc" {
  cidr_block           = var.lab6_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "lab6_subnet" {
  vpc_id     = aws_vpc.lab6_vpc.id
  cidr_block = var.lab6_subnet_cidr
}

// create a security group
resource "aws_security_group" "lab6_sg" {
  name        = "lab6-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.lab6_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// create a Ubuntu EC2 instance
resource "aws_instance" "lab6_instance" {
  ami                  = var.lab6_ubuntu_ami
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.lab6_key.key_name
  subnet_id            = aws_subnet.lab6_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "lab6-instance"
  }
}
