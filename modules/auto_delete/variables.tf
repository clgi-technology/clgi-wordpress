variable "vm_name" {
  description = "Name prefix for resources"
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance to auto-delete"
  type        = string
}
