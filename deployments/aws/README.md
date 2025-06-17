📄 deployments/aws/README.md
markdown
Copy
Edit
# AWS Terraform Configuration

This directory contains the Terraform code for deploying infrastructure to **Amazon Web Services (AWS)**. It is used by Terraform Cloud as the working directory for the `clgi-wordpress` workspace.

## Contents

- `main.tf` – Main infrastructure resources
- `variables.tf` – Input variables
- `outputs.tf` – Output values
- `provider.tf` – AWS provider configuration
- `terraform.tfvars` – Default variable values (optional)
- `backend.tf` – Remote backend config (if used)

This directory is intended to be executed by Terraform Cloud as part of a VCS-driven workflow.

**Do not delete this file** – it is required to make this folder visible as a valid working directory.
💾 Steps
Create deployments/aws/README.md with the content above.

Commit and push it:

bash
Copy
Edit
git add deployments/aws/README.md
git commit -m "Add README to satisfy Terraform Cloud working directory check"
git push
This will trigger a new plan in Terraform Cloud if the workspace is VCS-linked.
