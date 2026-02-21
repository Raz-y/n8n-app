# EC2 Instance
resource "aws_instance" "n8n" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.n8n_sg.id]
  # Pin to same AZ as data volume to enable attachment
  availability_zone = data.aws_availability_zones.available.names[0]

  user_data = templatefile("${path.module}/user_data/bootstrap.sh.tpl", {
    n8n_host           = "n8n.${var.domain_name}"
    n8n_user           = var.n8n_auth_user
    n8n_password       = var.n8n_auth_password
    n8n_encryption_key = var.n8n_encryption_key
    postgres_user      = var.postgres_user
    postgres_password  = var.postgres_password
    postgres_db        = var.postgres_db
    timezone           = var.generic_timezone
    docker_compose     = file("${path.module}/../../app/n8n/docker-compose.yml")
    caddyfile = templatefile("${path.module}/../../app/n8n/caddy/Caddyfile", {
      n8n_host = "n8n.${var.domain_name}"
    })
    n8n_service = file("${path.module}/../../app/n8n/systemd/n8n.service")
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  # Enforce IMDSv2 for enhanced security
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data_replace_on_change = true

  tags = {
    Name    = var.instance_name
    project = "n8n"
    owner   = var.owner
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
}
