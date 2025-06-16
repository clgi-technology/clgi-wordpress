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

  **NOTE:** All is done via Github action to easy allow for mobility but you may prefer to use command line as well.

---

Here’s your updated **Requirements** section with clickable links to the official websites for GitHub, Terraform, AWS, Google Cloud, and Microsoft Azure:

---

## 🌐 Requirements

* [**GitHub**](https://github.com) Account with [**Personal Access Token (PAT)**](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) — Needed to store Terraform code and run code via GitHub Actions
* [**Terraform**](https://www.terraform.io/) Account with [**API Token**](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/api-tokens) — Needed to store Terraform state so Terraform can remember what it has done previously
* [**AWS**](https://aws.amazon.com/), [**Google Cloud (GCP)**](https://cloud.google.com/), or [**Azure**](https://azure.microsoft.com/) Account with role credentials — Needed for Terraform to deploy a VM into your cloud provider

---


## 🚀 Quick Start

Certainly! Here are sample screenshots illustrating the steps in the **Quick Start** section of your README:

---

### 1. [**Clone the Repository**](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)


*Navigate to your repository on GitHub, click the green "Code" button, and copy the URL to clone the repository.*

![Alt Clone](https://docs.github.com/assets/cb-60499/mw-1440/images/help/repository/https-url-clone-cli.webp)
   ```bash
   git clone https://github.com/your-org/your-repo.git
   cd your-repo
  ```
---

### 2. Prepare Cloud Credentials and Add Them as GitHub [**Secrets**](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-development-environment-secrets-for-your-repository-or-organization#adding-secrets-for-a-repository)



*Go to your repository's "Settings" tab, select "Secrets and variables" > "Actions", and click "New repository secret" to add your cloud credentials.*

![Alt Secret](https://docs.github.com/assets/cb-28260/mw-1440/images/help/repository/repo-actions-settings.webp)
---

### 3. Trigger Deployment via GitHub Actions



*Navigate to the "Actions" tab of your repository, select the desired workflow, and click the "Run workflow" button.*

---

### 4. Wait for Deployment to Complete and Retrieve Your VM IP



*Monitor the workflow's progress in the "Actions" tab. Once completed, retrieve the VM's IP address from the workflow's output.*

---


## 📁 Project Structure

```plaintext
.
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
│   ├── sync-tfc-vars.yml           # Syncs github secrets with terraform cloud (run this first to sync credentials)
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



