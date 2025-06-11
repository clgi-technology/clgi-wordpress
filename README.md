# CLGI WordPress Multi-Cloud Deployment

## 📋 Project Overview
This repository enables one-click deployment of a WordPress or Django site to AWS, GCP, or Azure using Terraform and GitHub Actions. It supports mobile-triggered deployments via the GitHub iOS app and includes an option to clone the layout of CLGI.org.

---

## 🚀 Features
- **Multi-cloud support**: AWS, GCP, and Azure
- **Deployment modes**:
  - `production`: WordPress
  - `sandbox`: Django
- **Optional CLGI.org clone**: Replicates the look of the CLGI website
- **Mobile-friendly**: Trigger deployments from the GitHub mobile app
- **Infrastructure reuse**: Use existing key pairs or VPCs

---

## 📦 Prerequisites
- GitHub account with access to this repository
- AWS, GCP, or Azure account with credentials
- GitHub Secrets configured:
  - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`
  - `GCP_KEY_FILE` (JSON string)
  - `AZURE_CLIENT_ID`, `AZURE_SECRET`
  - `SSH_PASSWORD`, `SSH_PRIVATE_KEY`

---

## ⚙️ Deployment Instructions

### 1. Open GitHub (Web or Mobile)
- Navigate to the **Actions** tab
- Select **"Terraform Multi-Cloud Deployment"**
- Click **"Run workflow"**

### 2. Fill in the Inputs
- `cloud_provider`: AWS, GCP, or Azure
- `deployment_mode`: `production` (WordPress) or `sandbox` (Django)
- `setup_demo_clone`: `true` to clone CLGI.org layout
- `use_existing_key_pair`: `true` or `false`
- `existing_key_pair_name`: (if applicable)
- `use_existing_vpc`: `true` or `false`
- `existing_vpc_id`: (if applicable)

### 3. Wait for Deployment
- The workflow will provision a VM and install the selected stack
- The public IP will be printed in the logs

### 4. Access Your Site
- Open Safari or any browser
- Visit `http://<public-ip>` to view your deployed site

---

## 🗂️ File Structure

scripts/
├── install.sh                # Entry point
├── install-wordpress.sh      # WordPress setup
├── install-django.sh         # Django setup
└── install-clgi.sh           # CLGI.org theme setup
