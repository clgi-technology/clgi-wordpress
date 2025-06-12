# Cloud Selection and Mode
cloud_provider        = "AWS"            # Can be AWS, GCP, or Azure
deployment_mode       = "sandbox"        # sandbox = Django, production = WordPress
setup_demo_clone      = true            # true = static clone from URL, false = framework

# VM Configuration
vm_name               = "wordpress-server"
vm_size               = "t3.medium"
region                = "us-east-2"

# Networking
ssh_ip_address        = "108.79.241.230/32"  # Replace with your real IP

# Optional Clone Target
clone_target_url      = ""                # Only required if setup_demo_clone = true

# Secrets: Do NOT commit real values — use GitHub Secrets or environment variables!
ssh_password          = "YOUR_SECURE_SSH_PASSWORD"

# AWS Credentials (DO NOT COMMIT THESE — use GitHub Actions secrets or environment vars)
aws_access_key        = "REPLACE_WITH_ENV_VAR_OR_SECRET"
aws_secret_key        = "REPLACE_WITH_ENV_VAR_OR_SECRET"
aws_session_token     = "REPLACE_IF_NEEDED"

# GCP (Optional)
gcp_project           = "your-gcp-project-id"
gcp_key_file          = "your-gcp-key-file-path" # Path to GCP service account JSON key

# Azure Credentials (Optional)
azure_client_id       = "REPLACE_WITH_YOUR_AZURE_CLIENT_ID"
azure_secret          = "REPLACE_WITH_YOUR_AZURE_SECRET"
azure_tenant_id       = "REPLACE_WITH_YOUR_AZURE_TENANT_ID"
azure_subscription_id = "REPLACE_WITH_YOUR_AZURE_SUBSCRIPTION_ID"

# Optional DB/SMTP
db_password           = "example-db-password"
smtp_password         = "example-smtp-password"
