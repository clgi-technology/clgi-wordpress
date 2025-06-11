# Multi-Cloud Terraform VM Deployment

This project deploys a virtual machine (VM) to AWS, GCP, or Azure with options for sandbox (Django) or production (WordPress) modes.

---

## Features

- Supports AWS, GCP, and Azure in one codebase
- Dynamically selects VM types based on provider
- Optionally reuse existing key pairs, VPCs, and subnets
- Hardened security groups / firewall rules allowing SSH, HTTP, HTTPS only
- User data template for setup, including demo cloning
- GitHub Actions for CI/CD with workflow_dispatch inputs
- Secrets managed via GitHub Secrets (no plaintext passwords)
- Uses Terraform modules for clean code organization

---

## Getting Started

### Prerequisites

- Terraform >= 1.0
- GitHub repository with Secrets configured:
  - AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN (if needed)
  - GCP_KEY_FILE (JSON content)
  - AZURE_CLIENT_ID, AZURE_SECRET
  - SSH_PASSWORD (for initial VM login)
  - DB_PASSWORD (secure database password)
  - OPTIONAL: EXISTING_KEY_PAIR_NAME, EXISTING_VPC_ID, EXISTING_SUBNET_ID

### Deployment

1. Fork or clone this repository
2. Update your GitHub Secrets accordingly
3. Go to the **Actions** tab
4. Run the **Terraform Multi-Cloud Deployment** workflow manually
5. Select options (cloud provider, deployment mode, VM size, region, etc.)
6. Wait for deployment and check outputs for your VM IP

---

## Notes

- Existing resource reuse requires correct resource IDs/names in Secrets
- VM setup installs your app with demo cloning if enabled
- Security groups limit access to SSH, HTTP, and HTTPS ports only
- User data script is loaded via a Terraform templatefile for flexibility
- You can extend this project with HTTPS certs (e.g., Let's Encrypt) and monitoring

---

## Contributions

Feel free to open issues or PRs for enhancements or bug fixes!

---

## License

MIT License
