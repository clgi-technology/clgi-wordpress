variable "ssh_ip_address" {
  description = "CIDR block to allow SSH access (e.g. 203.0.113.0/32)"
  type        = string
}

variable "project_name" {
  description = "Name of the project to prefix resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}
