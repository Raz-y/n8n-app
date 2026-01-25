output "ec2_public_ip" {
  description = "Elastic IP address of the n8n instance"
  value       = aws_eip.n8n.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.n8n.id
}

output "n8n_url" {
  description = "URL to access n8n"
  value       = "https://n8n.${var.domain_name}"
}

output "route53_nameservers" {
  description = "Update your domain registrar with these NS records"
  value       = aws_route53_zone.primary.name_servers
}

output "ebs_volume_id" {
  description = "EBS data volume ID (protected from destruction)"
  value       = aws_ebs_volume.n8n_data.id
}
