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
- ✅ Tech stack provisioning: Django or WordPress  (Not Working at the moment)
- ✅ Auto-expiry logic (auto-delete infrastructure after 24h)  (Not Working at the moment)
- ✅ GitHub Actions CI/CD integration  
- ✅ Optional website cloning on VM for demo/testing (Not working at the moment)

  **NOTE:** All is done via Github action to easy allow for mobility but you may prefer to use command line as well.

---

Here’s your updated **Requirements** section with clickable links to the official websites for GitHub, Terraform, AWS, Google Cloud, and Microsoft Azure:

---

## 🌐 Requirements

* [**GitHub**](https://github.com) Account with [**Personal Access Token (PAT)**](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) — Needed to store Terraform code and run code via GitHub Actions
* [**Terraform**](https://app.terraform.io/app/) Account with [**API Token**](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/api-tokens) — Needed to store Terraform state so Terraform can remember what it has done previously as well as secrets like AWS, Google, Azure. Store all secrets here.
* [**AWS**](https://aws.amazon.com/), [**Google Cloud (GCP)**](https://cloud.google.com/), or [**Azure**](https://azure.microsoft.com/) Account with role credentials — Needed for Terraform to deploy a VM into your cloud provider

---


## 🚀 Quick Start

Certainly! Here are sample screenshots illustrating the steps in the **Quick Start** section of your README:

---

### 1. [**Clone the Repository**](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)


*Navigate to your repository on GitHub, click the green "Code" button, and copy the URL to clone the repository into your Github account.*

![Alt Clone](https://docs.github.com/assets/cb-60499/mw-1440/images/help/repository/https-url-clone-cli.webp)
   ```bash
   git clone https://github.com/your-org/your-repo.git
   cd your-repo
  ```
---

### 2. Prepare Cloud Credentials and Add Them as Terraform [**Secrets**](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables/managing-variables) and Github [**Secrets**]([https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables/managing-variables](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions))



*In Terraform dashboard Go to your repository's "Workspace" tab, select "Variables" and click "New variable".*

![Alt Secret](https://i.sstatic.net/tuj70.png)

```

```
*In Github dashboard Go to your repository's "settings" tab, select "Actions"  and select "Secrets" and click "New Secret".*

![Alt Secret2](https://docs.github.com/assets/cb-57155/mw-1440/images/help/repository/actions-secrets-tab.webp)

---

### 3. Trigger Deployment via Terraform Run Triggers or via GitHub Actions [Workflow](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-workflow-runs/manually-running-a-workflow)


*Navigate to the "Actions" tab of your repository*

![Alt Workflow1](https://docs.github.com/assets/cb-12958/mw-1440/images/help/repository/actions-tab-global-nav-update.webp)

*Select the desired workflow, and click the "Run workflow" button.*
![Alt Workflow2](https://docs.github.com/assets/cb-60473/mw-1440/images/help/repository/actions-select-workflow-2022.webp)

---

### 4. Wait for Deployment to Complete and Retrieve Your VM IP from the [Workflow Run Log](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/monitoring-workflows/using-workflow-run-logs)



*Monitor the workflow's progress in the "Actions" tab. Once completed, retrieve the VM's IP address from the workflow's run log output.*

![Alt Workflow3](https://docs.github.com/assets/cb-33371/mw-1440/images/help/repository/copy-link-button-updated-2.webp)
---


### 5. Retrieve SSH info
Users Can Access the SSH Key 2 ways:
From GitHub Actions Logs: They can view and copy the private key.

From GitHub Artifacts: Users can download private_key.pem from the Actions run.

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
│   ├── scrape_clgi.py
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


---

## ⚙️ Terraform Configuration Steps

Follow these steps to configure Terraform Cloud and prepare your environment for deployments:

### 1. Create a Terraform Cloud Account & Organization

- Sign up or log in at [https://app.terraform.io](https://app.terraform.io).
- Create an organization if you don’t already have one.

### 2. Create a Workspace Connected to Your GitHub Repo

- In your Terraform Cloud organization, create a new workspace.
- Choose **Version Control Workflow** and connect your GitHub repository.
- Select the branch you want to track (e.g., `main`).
- Set the **Terraform Working Directory** to the appropriate subfolder, e.g.:
  - `deployments/aws`  
  - `deployments/gcp`  
  - `deployments/azure`

### 3. Configure Workspace Variables

In your Terraform Cloud workspace, add the following **Terraform Variables** (under **Variables > Terraform Variables**):
NOTE: Case sensitive, keep names lower case in Terraform and all Upper case in Github Secret

| Name                  | Type     | Sensitive | Description                                      |
|-----------------------|----------|-----------|------------------------------------------------|
| `cloud_provider`      | string   | No        | Select your cloud provider: `aws`, `gcp`, or `azure` |
| `deployment_mode`     | string   | No        | `sandbox` or `production`                        |
| `auto_delete_after_24h` | boolean  | No        | `true` or `false` to auto-delete after 24 hours |
| `vm_name`             | string   | No        | Name of the virtual machine                      |
| `vm_size`             | string   | No        | Instance size (e.g. `t3.micro` for AWS)         |
| `ssh_allowed_ip`      | string   | No        | CIDR range allowed for SSH access                |
| `setup_demo_clone`    | boolean  | No        | `true` to clone demo website, otherwise `false` |
| `clone_target_url`    | string   | No        | URL or repo for demo website (optional)          |
| `region`             | string   | No        | Cloud region (optional fallback)                 |

Add **Environment Variables** or **Terraform Variables** for your cloud credentials as **sensitive**:

| Name                     | Description                         |
|--------------------------|-----------------------------------|
| AWS_ACCESS_KEY_ID         | AWS Access Key ID                  |
| AWS_SECRET_ACCESS_KEY     | AWS Secret Access Key              |
| AWS_SESSION_TOKEN        | AWS Session Token (optional)      |
| GCP_CREDENTIALS          | GCP Service Account JSON           |
| AZURE_CLIENT_ID          | Azure Client ID                   |
| AZURE_CLIENT_SECRET      | Azure Client Secret               |
| AZURE_SUBSCRIPTION_ID    | Azure Subscription ID             |
| AZURE_TENANT_ID          | Azure Tenant ID                   |

### 4. Configure GitHub Secrets (for GitHub Actions)

Set these secrets in your GitHub repository **Settings > Secrets**:

- `TF_TOKEN_APP_TERRAFORM_IO` — Your Terraform Cloud API token
- `SSH_PRIVATE_KEY` — Private SSH key (PEM format)
- `SSH_PUBLIC_KEY` — Public SSH key

Include any cloud provider secrets as needed.

### 5. Trigger Terraform Runs

- Push changes to your GitHub repo branch to trigger Terraform Cloud runs automatically.
- Or manually trigger runs in Terraform Cloud UI.
- GitHub Actions will perform Terraform **plan** and output the results in the Actions logs.
- Terraform Cloud manages **apply** steps according to the VCS workflow.

### 6. Monitor Deployment & Retrieve Outputs

- View Terraform plan results in GitHub Actions logs.
- View apply status, logs, and state in Terraform Cloud workspace Runs.
- Once applied, retrieve your VM’s public IP address from Terraform outputs.
- SSH into your VM using the private key from GitHub Actions artifacts or your local copy.

---

**Tip:** Review your variables and credentials carefully to avoid leaks and ensure least privilege access.

---

## 🌐 Terraform Cloud VCS Integration (Optional)

Terraform Cloud is configured to connect directly to this GitHub repository via the VCS integration. This means:

- Terraform Cloud automatically runs plans when changes are pushed.
- Applies are managed by Terraform Cloud, respecting VCS as the single source of truth.
- You cannot run `terraform apply` manually or via GitHub Actions for these workspaces.
- Apply runs and state changes are visible **only inside the Terraform Cloud UI**.

### Where to Find Logs:

| Task                  | Location                  |
|-----------------------|---------------------------|
| Plan                  | GitHub Actions run logs   |
| Apply                 | Terraform Cloud UI        |
| State Management      | Terraform Cloud UI        |
| Artifact Downloads    | GitHub Actions Artifacts  |

To enable, commit out in the terraflow.yml workflow file the lines for terraform apply.

---

### Where to Configure Credentials and Variables

To enable the deployment pipeline, you need to configure secrets and variables in **both Terraform Cloud** and **GitHub**:

- **Terraform Cloud Workspace Variables:**  
  Store cloud provider credentials (AWS keys, GCP JSON, Azure secrets), deployment parameters (VM name, region, instance size), and SSH keys as Terraform variables. These are used during Terraform runs to provision infrastructure.

- **GitHub Repository Secrets:**  
  Store the Terraform Cloud API token (`TF_TOKEN_APP_TERRAFORM_IO`) and SSH keys here. GitHub Actions workflows use these secrets to authenticate with Terraform Cloud and handle provisioning securely.

This separation ensures that sensitive data is managed securely, and each platform has the data it needs to perform its role.


---

## 🌐 GitHub Actions Workflow
The GitHub Actions workflow triggers Terraform `init`, `validate`, and `plan` commands on every push or manual run.

**Important:**  
Due to the VCS connection enforced by Terraform Cloud, **`terraform apply` is no longer run in GitHub Actions**.

Trigger deployments via GitHub UI or CLI.

Workflow file: .github/workflows/terraform.yml

**Deployment Steps:**
Obtain temporary AWS credentials (if deploying to AWS): 
https://churchofthelivinggod.awsapps.com/start/#/?tab=accounts

AWS_ACCESS_KEY_ID | AWS_SECRET_ACCESS_KEY | AWS_SESSION_TOKEN


Add these credentials as Terraform variables under Workspace → Settings → Variables.

Option 1: Trigger the workflow from GitHub Actions → Select the workflow → Run workflow → Provide necessary inputs 

Option 2: Trigger the workflow from Terraform Cloud → Terraform Cloud → Workspace Settings → Run Triggers | Click "Create a Run Trigger" and Select GitHub Actions as the destination

**Workflow User Inputs**

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

🔐 **Terraform Secrets Configuration**
Add the following secrets to your repository for Terraform to use:
Add to Github Secrets the TF_TOKEN_APP_TERRAFORM_IO for Github and Terraform to talk to each other.

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

🧩 **Optional: Demo Website Scrapping (static homepage cloning only)**
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



