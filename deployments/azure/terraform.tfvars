cloud_provider      = "azure"
deployment_mode     = "sandbox" # or "production"
region              = "eastus"
vm_name             = "clgi-deploy"
vm_size             = "Standard_B2s"
ssh_allowed_ip      = "0.0.0.0/0"
auto_delete_after_24h = false

# Azure-specific (often pulled from env vars)
azure_client_id       = ""
azure_client_secret   = ""
azure_subscription_id = ""
azure_tenant_id       = ""

# SSH access
ssh_public_key      = ""
ssh_private_key     = ""
ssh_password        = ""
