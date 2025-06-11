cloud_provider        = "AWS"   # Can be AWS, GCP, or Azure
deployment_mode       = "sandbox"  # sandbox (Django) or production (WordPress)

# VM Configuration
vm_name               = "wordpress-server"
vm_size               = "t3.medium"
region                = "us-west-2"

# GitHub Integration
github_token          = "ghp._80WwSUDUvGSINnoGaP8QqlYkR5739Z40GxQE"
github_repo           = "clgi-wordpress"

# Cloud Credentials (Use GitHub Secrets Instead!)
gcp_project           = "your-gcp-project-id"
ssh_password          = ""

# AWS Credentials (DO NOT store secrets here—use environment variables!)
# AWS Configuration
aws_access_key        = "${var.aws_access_key}"
aws_secret_key        = "${var.aws_secret_key}"
aws_session_token     = "${var.aws_session_token}"  # If using temporary credentials
region                = "us-west-2"                 # Ensure this matches your AWS setup