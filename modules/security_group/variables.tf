variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "ssh_ip_address" {
  description = "The allowed IP address for SSH access"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider to use (AWS, GCP, or Azure)"
  type        = string
}
