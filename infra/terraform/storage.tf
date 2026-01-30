# Encrypted EBS volume for n8n data persistence
resource "aws_ebs_volume" "n8n_data" {
  availability_zone = aws_instance.n8n.availability_zone
  size              = 30
  type              = "gp3"
  encrypted         = true
  iops              = 3000
  throughput        = 125

  tags = {
    Name    = "n8n-data"
    project = "n8n"
    owner   = var.owner
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Attach data volume to EC2 instance
resource "aws_volume_attachment" "n8n_data_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.n8n_data.id
  instance_id = aws_instance.n8n.id
}
