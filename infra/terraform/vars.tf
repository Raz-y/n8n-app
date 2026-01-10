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

variable "ssh_ingress_cidr" {
  description = "ip in CIDR notation, e.g. 1.2.3.4./32"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the existing EC2 SSH key pair"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type for the EC2 instance"
  type        = string
}
