provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# AMI 
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# EC2 INSTANCE
resource "aws_instance" "n8n" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.n8n_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  tags = {
    Name    = var.instance_name
    project = "n8n"
    owner   = "raz"
  }
}

# Elastic IP
resource "aws_eip" "n8n" {
  domain = "vpc"

  tags = {
    Name      = "n8n-eip"
    ManagedBy = "terraform"
  }
}

resource "aws_eip_association" "n8n" {
  instance_id   = aws_instance.n8n.id
  allocation_id = aws_eip.n8n.id
}

# SG
resource "aws_security_group" "n8n_sg" {
  name        = "${var.instance_name}-sg"
  description = "SG for n8n host (SSH restricted, HTTP/HTTPS open)"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }


  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.instance_name}-sg"
    project = "n8n"
    owner   = "raz"
  }

}
