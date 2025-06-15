🧾 README.md – Terraform Multi-Cloud Deployment
markdown
Copy
Edit
# 🌐 Terraform Multi-Cloud Deployment Framework

This project provides a modular, cloud-agnostic Terraform deployment system for provisioning VMs on **AWS**, **GCP**, and **Azure**, with support for:

- ✅ Environment-based deployments (sandbox vs. production)
- ✅ Tech stack provisioning (Django or WordPress)
- ✅ Auto-expiry logic (auto-delete after 24h)
- ✅ GitHub Actions CI/CD integration
- ✅ Optional website clone on VM

---

## 📁 Project Structure

```bash
.
├── deployments/
│   ├── aws/         # Terraform root module for AWS
│   ├── gcp/         # Terraform root module for GCP
│   └── azure/       # Terraform root module for Azure
├── modules/
│   ├── aws/         # Reusable AWS module
│   ├── gcp/         # Reusable GCP module
│   ├── azure/       # Reusable Azure module
│   └── security_groups/
├── templates/
│   └── user_data.sh.tmpl  # Cloud-init bootstrap template
├── scripts/
│   ├── install-django.sh
│   ├── install-wordpress.sh
│   └── install-clgi.sh
├── .github/workflows/
│   └── terraform.yml     # GitHub Actions workflow
├── legacy/
│   ├── main.tf           # 🛑 Deprecated root entry point
│   ├── variables.tf
│   ├── provider.tf
│   ├── outputs.tf
│   └── terraform.tfvars
└── README.md
🚀 Deployment Options
Cloud Provider	Modes	Tech Stack
AWS	sandbox / production	Django or WordPress
GCP	sandbox / production	Django or WordPress
Azure	sandbox / production	Django or WordPress

⚙️ GitHub Actions Workflow
Trigger deployment from GitHub UI or CLI:

File: .github/workflows/terraform.yml

Inputs:

cloud_provider: aws, gcp, azure

deployment_mode: sandbox or production

auto_delete_after_24h: true / false

vm_name, vm_size, region, ssh_allowed_cidr

Secrets required: SSH_PUBLIC_KEY, AWS_ACCESS_KEY_ID, etc.

Workflow runs:

Initializes Terraform in the selected deployment folder

Applies infrastructure

Provisions software via user_data.sh.tmpl

Outputs deployed VM IP

🔁 Optional: Demo Website Cloning
Set the following variables (via terraform.tfvars or GitHub inputs) to clone a site to the VM:

h
Copy
Edit
setup_demo_clone   = true
clone_target_url   = "https://github.com/example/my-demo-app.git"
🧨 Destroying Infrastructure
A separate workflow (terraform-destroy.yml) can be used to destroy VMs by:

Cloud provider

Instance name or tag

Expired destroy_after timestamp (coming soon)

🧹 Legacy Files
Files previously in the project root have been moved to /legacy and are no longer used. All deployment logic now runs under the deployments/<cloud>/ structure.

📬 Feedback & Contributions
Feel free to open issues, PRs, or suggest new cloud providers or frameworks you'd like integrated!

yaml
Copy
Edit
