🌐 Terraform Multi-Cloud Deployment
This project enables deployment of Django (sandbox) or WordPress (production) environments to AWS, GCP, or Azure, using:

Modularized Terraform infrastructure

GitHub Actions workflows

Separate deployment environments (workspaces) per cloud provider

📁 Project Structure


|   main.tf
|   outputs.tf
|   README.md
|   terraform.tfvars
|   terraform_deploy_key
|   terraform_deploy_key.pub
|   variables.tf
|
+---.github
|   \---workflows
|           terraform-apply-only.yml
|           terraform.yml
|
+---clgi-wordpress
|   |   main.tf
|   |   outputs.tf
|   |   provider.tf
|   |   README.md
|   |   terraform.tfvars
|   |   variables.tf
|   |
|   +---.github
|   |   \---workflows
|   |           deploy.yml
|   |           terraform-apply-only.yml
|   |           terraform.yml
|   |
|   +---deployments
|   |   +---aws
|   |   |       main.tf
|   |   |       terraform.tfvars
|   |   |       variables.tf
|   |   |
|   |   +---azure
|   |   |       main.tf
|   |   |       terraform.tfvars
|   |   |       variables.tf
|   |   |
|   |   \---gcp
|   |           main.tf
|   |           terraform.tfvars
|   |           variables.tf
|   |
|   +---examples
|   |   +---django
|   |   |       main.tf
|   |   |
|   |   \---wordpress
|   |           main.tf
|   |
|   +---modules
|   |   +---aws
|   |   |       main.tf
|   |   |       outputs.tf
|   |   |       variables.tf
|   |   |
|   |   +---azure
|   |   |       main.tf
|   |   |       outputs.tf
|   |   |       variables.tf
|   |   |
|   |   +---cloud_vm
|   |   |   |   outputs.tf
|   |   |   |
|   |   |   \---security_group
|   |   |           main.tf
|   |   |           outputs.tf
|   |   |           variables.tf
|   |   |
|   |   +---gcp
|   |   |       main.tf
|   |   |       outputs.tf
|   |   |       variables.tf
|   |   |
|   |   \---security_group
|   |           main.tf
|   |           outputs.tf
|   |           variables.tf
|   |           versions.txt
|   |
|   +---scripts
|   |       install-clgi.sh
|   |       install-django.sh
|   |       install-wordpress.sh
|   |
|   \---templates
|           user_data.sh.tmpl


🚀 Deployment Options
Cloud Provider	Deployment Modes	Tech Stack
AWS	sandbox, production	Django or WordPress
GCP	sandbox, production	Django or WordPress
Azure	sandbox, production	Django or WordPress

...

✅ Requirements
Terraform v1.3+

GitHub CLI (for manual dispatch)

SSH key pair (used to SSH into VMs)

🔐 GitHub Secrets
Secret Name	Description
AWS_ACCESS_KEY_ID	AWS Access Key
AWS_SECRET_ACCESS_KEY	AWS Secret Key
AWS_SESSION_TOKEN	AWS Session Token (optional)
SSH_PUBLIC_KEY	Contents of your id_rsa.pub file
SSH_PRIVATE_KEY	Contents of your id_rsa file
SSH_PASSWORD	Optional login password

🧠 How It Works
Modular Design
Infrastructure logic is abstracted into reusable modules under modules/*.

Deployment Workspaces
Each cloud has its own Terraform workspace under deployments/{cloud} with its own backend, providers, and variable wiring.

GitHub Actions Workflow
A single workflow (.github/workflows/terraform.yml) dynamically applies Terraform configurations based on user input (aws, gcp, azure).

📦 How to Deploy
GitHub Actions (Recommended)
Go to Actions tab

Select Terraform Multi-Cloud Deployment

Click "Run workflow"

Choose:

Cloud provider (aws, gcp, azure)

Deployment mode (sandbox, production)

VM name, region, CIDR, etc.

Deployment runs automatically using the correct workspace.

🧹 Auto-Deletion (Optional)
For sandbox deployments, you can opt into a 24-hour auto-deletion feature by setting:

yaml
Copy
Edit
auto_delete_after_24h: true
This creates a VM tag or cron trigger (implementation varies by module).

🛠️ Manual Deployment (CLI)
To deploy to AWS manually:

bash
Copy
Edit
cd deployments/aws

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -auto-approve -var-file=terraform.tfvars
📤 Outputs
Terraform will output the public IP of the deployed VM, visible in both the CLI and GitHub Action logs.

