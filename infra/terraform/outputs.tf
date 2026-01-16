output "public_ip" {
  value       = aws_instance.n8n.public_ip
  description = "Public IPv4 address"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/${var.ssh_key_name} ec2-user@${aws_instance.n8n.public_ip}"
  description = "SSH command"
}

output "route53_name_servers" {
  value = aws_route53_zone.primary.name_servers
}
