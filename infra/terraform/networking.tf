# Elastic IP for static public IP
resource "aws_eip" "n8n" {
  domain = "vpc"

  tags = {
    Name    = "n8n-eip"
    project = "n8n"
    owner   = var.owner
  }
}

# Associate EIP with EC2 instance
resource "aws_eip_association" "n8n" {
  instance_id   = aws_instance.n8n.id
  allocation_id = aws_eip.n8n.id
}

# Security Group - HTTP/HTTPS open, access via SSM Session Manager
resource "aws_security_group" "n8n_sg" {
  name        = "${var.instance_name}-sg"
  description = "SG for n8n host (HTTP/HTTPS open, access via SSM Session Manager)"

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

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.instance_name}-sg"
    project = "n8n"
    owner   = var.owner
  }
}

# Route53 hosted zone for domain
resource "aws_route53_zone" "primary" {
  name = var.domain_name

  tags = {
    Name    = "${var.domain_name}-zone"
    project = "n8n"
    owner   = var.owner
  }
}

# DNS A record for n8n service
resource "aws_route53_record" "n8n" {
  zone_id = aws_route53_zone.primary.id
  name    = "n8n.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.n8n.public_ip]
}
