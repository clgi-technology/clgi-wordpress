aws_region            = "us-west-2"
aws_access_key        = "REPLACE_ME" # Use env vars or GitHub secrets
aws_secret_key        = "REPLACE_ME"
aws_session_token     = "REPLACE_IF_NEEDED"

vm_name               = "clgi-aws-vm"
vm_size               = "t3.medium"
ssh_allowed_ip        = "0.0.0.0/0"
ssh_public_key        = "REPLACE_WITH_YOUR_SSH_PUBLIC_KEY"
ssh_password          = "REPLACE_ME"
deployment_mode       = "sandbox"
setup_demo_clone      = false
clone_target_url      = "https://www.clgi.org"
auto_delete_after_24h = false
