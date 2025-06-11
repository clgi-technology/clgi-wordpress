variable "project_name" {
  type        = string
  description = "Project name prefix for resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group will be created"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH"
  default     = ["0.0.0.0/0"]  # Change to more restrictive CIDRs in production!
}

variable "allowed_http_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to HTTP"
  default     = ["0.0.0.0/0"]
}

variable "allowed_app_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to app port"
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  type        = number
  description = "Custom app port to allow inbound traffic"
  default     = 8000
}
