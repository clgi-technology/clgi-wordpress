cloud_provider      = "gcp"
deployment_mode     = "sandbox" # or "production"
region              = "us-central1"
vm_name             = "clgi-deploy"
vm_size             = "e2-medium"
ssh_allowed_ip      = "0.0.0.0/0"
auto_delete_after_24h = false

# GCP-specific
gcp_project_id      = "your-gcp-project-id"
gcp_credentials     = "" # Typically loaded via GOOGLE_CREDENTIALS env var

# SSH access
ssh_public_key      = ""
ssh_private_key     = ""
ssh_password        = ""
