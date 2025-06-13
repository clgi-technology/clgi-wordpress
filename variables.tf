variable "cloud_provider" {}
variable "region" {}
variable "zone" {
  default = "us-central1-a"
}
variable "vm_name" {}
variable "vm_size" {
  default = "t2.micro"
}
variable "ssh_allowed_ip" {
  default = "0.0.0.0/0"
}
variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}
variable "gcp_project" {
  default = ""
}
variable "gcp_key_file" {
  default = ""
}
variable "azure_client_id" {
  default = ""
}
variable "azure_secret" {
  default = ""
}
variable "azure_tenant_id" {
  default = ""
}
variable "azure_subscription_id" {
  default = ""
}
