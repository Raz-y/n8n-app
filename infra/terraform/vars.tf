variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "raz-admin"
}

variable "owner" {
  description = "Owner name for tags"
  type        = string
  default     = "raz"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type for the EC2 instance"
  type        = string
}

variable "domain_name" {
  type        = string
  description = "Your root domain, e.g. example.com"
}

variable "n8n_auth_user" {
  description = "n8n basic auth username"
  type        = string
  sensitive   = true
}

variable "n8n_auth_password" {
  description = "n8n basic auth password"
  type        = string
  sensitive   = true
}

variable "n8n_encryption_key" {
  description = "n8n encryption key for credentials (generate with: openssl rand -hex 32)"
  type        = string
  sensitive   = true
}

