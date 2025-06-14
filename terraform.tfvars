# Root terraform.tfvars file

# Cloud Selection and Mode
cloud_provider        = "aws"            # lowercase to match expected variable
deployment_mode       = "sandbox"        # sandbox = Django, production = WordPress
setup_demo_clone      = false
auto_delete_after_24h = true

# VM Configuration
vm_name               = "wordpress-server"
vm_size               = "t3.medium"
aws_region            = "us-west-2"      # explicitly for AWS module

# Networking
ssh_allowed_ip        = "108.79.241.230/32"  # renamed to match variable name

# Optional Clone Target
clone_target_url      = "www.clgi.org"                # required only if setup_demo_clone = true

# Secrets: Do NOT commit real values — use GitHub Secrets or environment variables!
ssh_password          = "YOUR_SECURE_SSH_PASSWORD"
ssh_public_key_path   = "path/to/your/id_rsa.pub"

# AWS Credentials (DO NOT COMMIT THESE — use GitHub Actions secrets or environment vars)
aws_access_key        = "REPLACE_WITH_ENV_VAR_OR_SECRET"
aws_secret_key        = "REPLACE_WITH_ENV_VAR_OR_SECRET"
aws_session_token     = "REPLACE_IF_NEEDED"

# GCP (optional)
gcp_project           = "dummy"    # "your-gcp-project-id"
gcp_key_file          = "dummy"    # "your-gcp-key-file-path"


# Azure Credentials (optional)
azure_client_id       = "dummy"    # "REPLACE_WITH_YOUR_AZURE_CLIENT_ID"
azure_secret          = "dummy"    # "REPLACE_WITH_YOUR_AZURE_SECRET"
azure_tenant_id       = "dummy"    # "REPLACE_WITH_YOUR_AZURE_TENANT_ID"
azure_subscription_id = "dummy"    # "REPLACE_WITH_YOUR_AZURE_SUBSCRIPTION_ID"
azure_region          = "dummy"    # specify if used

# Optional DB/SMTP passwords - declare these in variables.tf if used
db_password           = ""    # "example-db-password"
smtp_password         = ""    # "example-smtp-password"
