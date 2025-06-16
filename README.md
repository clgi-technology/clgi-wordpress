# 🧾 Terraform Multi-Cloud Deployment

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/your-org/your-repo/terraform.yml?branch=main&label=CI/CD&logo=github)](https://github.com/your-org/your-repo/actions/workflows/terraform.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub Repo Stars](https://img.shields.io/github/stars/your-org/your-repo?style=social)](https://github.com/your-org/your-repo/stargazers)

---

## 📌 Table of Contents

- [Overview](#-overview)  
- [Quick Start](#-quick-start)  
- [Project Structure](#-project-structure)  
- [Deployment Options](#-deployment-options)  
- [GitHub Actions Workflow](#-github-actions-workflow)  
- [GitHub Secrets Configuration](#-github-secrets-configuration)  
- [Demo Website Cloning](#-optional-demo-website-cloning)  
- [Destroying Infrastructure](#-destroying-infrastructure)  
- [Legacy Files](#-legacy-files)  
- [Feedback & Contributions](#-feedback--contributions)  

---

## 🌐 Overview

This project provides a **modular, cloud-agnostic Terraform deployment system** for provisioning virtual machines on **AWS, GCP, and Azure**, with features including:

- ✅ Environment-based deployments (`sandbox` vs `production`)  
- ✅ Tech stack provisioning: Django or WordPress  
- ✅ Auto-expiry logic (auto-delete infrastructure after 24h)  
- ✅ GitHub Actions CI/CD integration  
- ✅ Optional website cloning on VM for demo/testing  

---

## 🚀 Quick Start

1. **Clone this repo**:

      ```bash
   git clone https://github.com/your-org/your-repo.git
   cd your-repo

**2. Prepare your cloud credentials and add them as GitHub secrets (see GitHub Secrets Configuration).**

**3. Trigger deployment via GitHub Actions:**

Go to your repo's Actions tab.

Select the Terraform workflow.

Click Run workflow.

Provide inputs (e.g., cloud_provider, deployment_mode, vm_name, etc.).

**4. Wait for deployment to complete and retrieve your VM IP from workflow outputs.**



## 📁 Project Structure

```plaintext
clgi-wordpress/
├── deployments/
│   ├── aws/         # Terraform root module for AWS
│         ├── main.tf
│         ├── provider.tf
│         ├── variables.tf
│         ├── outputs.tf
│         ├── terraform.tfvars
│         ├── backend.tf
│   ├── gcp/         # Terraform root module for GCP
│         ├── main.tf
│         ├── variables.tf
│         ├── outputs.tf
│         ├── terraform.tfvars
│         ├── backend.tf
│   └── azure/       # Terraform root module for Azure
│         ├── main.tf
│         ├── variables.tf
│         ├── outputs.tf
│         ├── terraform.tfvars
│         ├── backend.tf
├── modules/
│   ├── aws/         # Reusable AWS module
│         ├── main.tf
│         ├── variables.tf
│         ├── outputs.tf
│   ├── gcp/         # Reusable GCP module
│         ├── main.tf
│         ├── variables.tf
│         ├── outputs.tf
│   ├── azure/       # Reusable Azure module
│         ├── main.tf
│         ├── variables.tf
│         ├── outputs.tf
│   └── security_group/
│         ├── main.tf
│         ├── variables.tf
│         ├── outputs.tf
├── templates/
│   └── user_data.sh.tmpl  # Cloud-init bootstrap template
├── scripts/
│   ├── clone_clgi.py
│   ├── install-django.sh
│   ├── install-wordpress.sh
│   └── install-clgi.sh
├── .github/workflows/
│   ├── terraform-apply-only.yml    # GitHub Actions workflow for running terraform apply command only
│   ├── terraform-auto-destroy.yml  # GitHub Actions workflow for destroying previous deployment
│   └── terraform.yml               # GitHub Actions workflow for deployment
├── legacy/
│   ├── main.tf            # 🛑 Deprecated root entry point
│   ├── variables.tf
│   ├── provider.tf
│   ├── outputs.tf
│   └── terraform.tfvars
└── README.md
```


## 🚀 Deployment Options

| Cloud Provider | Modes               | Tech Stack          |
|----------------|---------------------|----------------------|
| AWS            | sandbox / production | Django or WordPress |
| GCP            | sandbox / production | Django or WordPress |
| Azure          | sandbox / production | Django or WordPress |


⚙️ **GitHub Actions Workflow**
Trigger deployments via GitHub UI or CLI.

Workflow file: .github/workflows/terraform.yml

**Deployment Steps:**
Obtain temporary AWS credentials (if deploying to AWS): 
https://churchofthelivinggod.awsapps.com/start/#/?tab=accounts

AWS_ACCESS_KEY_ID | AWS_SECRET_ACCESS_KEY | AWS_SESSION_TOKEN


Add these credentials as GitHub secrets under Settings → Secrets and variables → Actions.

Trigger the workflow from GitHub Actions → Select the workflow → Run workflow → Provide necessary inputs:

cloud_provider (aws, gcp, azure)

deployment_mode (sandbox or production)

auto_delete_after_24h (true/false)

vm_name, vm_size, region, ssh_allowed_cidr

**Workflow tasks:**

Initialize Terraform in the target deployment folder.

Apply infrastructure provisioning.

Provision software with user_data.sh.tmpl.

Output VM IP address.

**After the workflow runs, the user can:**

Insert VM IP in browser and access scrapped static page for demo or configure VM: Go to Actions tab → [this workflow run] → Artifacts section

Download the ssh-private-key artifact (a zip containing the private key file)

Extract and use it for SSH:

```bash
chmod 600 id_rsa
ssh -i id_rsa ubuntu@<VM_IP>
```

🔐 **GitHub Secrets Configuration**
Add the following secrets to your repository:

| Secret Name           | Description                                         |
|------------------------|-----------------------------------------------------|
| SSH_PRIVATE_KEY        | Private SSH key for accessing provisioned VMs (PEM) |
| SSH_PUBLIC_KEY         | Corresponding public SSH key                        |
| SSH_PASSWORD           | SSH password for VM login (optional)               |
| AWS_ACCESS_KEY_ID      | AWS access key ID                                   |
| AWS_SECRET_ACCESS_KEY  | AWS secret access key                               |
| AWS_SESSION_TOKEN      | AWS session token (optional)                        |
| GCP_CREDENTIALS        | JSON content of your GCP service account key        |
| AZURE_CLIENT_ID        | Azure Client ID for service principal               |
| AZURE_CLIENT_SECRET    | Azure Client Secret for service principal           |
| AZURE_SUBSCRIPTION_ID  | Azure Subscription ID                               |
| AZURE_TENANT_ID        | Azure Tenant ID                                     |


**Important:**

Secrets are injected as environment variables automatically.

Grant least privilege access to these credentials.

**Do not commit secrets in code or repo.**

🧩 **Optional: Demo Website Cloning**
Set these Terraform variables to enable cloning a demo app into the VM:

```bash
setup_demo_clone = true
clone_target_url = "https://github.com/example/my-demo-app.git"
```

🧨 **Destroying Infrastructure**
Use terraform-destroy.yml workflow to tear down infrastructure. It supports:

Targeting specific cloud providers

Selecting instances by name or tag

Auto-destroy with expiration timestamps (coming soon)

🧹 **Legacy Files**
Deprecated files moved to /legacy folder. Active deployment logic is under 

```bash
deployments/<cloud-platform>/.
```

📬 **Feedback & Contributions**
Contributions are welcome! Please open issues, submit pull requests, or suggest new features and cloud providers.



