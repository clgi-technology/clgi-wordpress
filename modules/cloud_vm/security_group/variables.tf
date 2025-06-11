variable "project_name" {
  type        = string
  description = "Project name prefix for resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group will be created"
}

variable "ssh_ip_address" {
  type        = string
  description = "CIDR block for SSH access (e.g., your IP address)"
}
