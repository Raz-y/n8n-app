# Encrypted EBS volume for n8n data persistence
resource "aws_ebs_volume" "n8n_data" {
  # Pin to specific AZ to prevent data loss when instance is replaced
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 30
  type              = "gp3"
  encrypted         = true
  iops              = 3000
  throughput        = 125

  tags = {
    Name    = "n8n-data"
    project = "n8n"
    owner   = var.owner
    # Backup  = "true"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Attach data volume to EC2 instance
resource "aws_volume_attachment" "n8n_data_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.n8n_data.id
  instance_id = aws_instance.n8n.id
}
