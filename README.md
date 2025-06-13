# 🌐 Multi-Cloud VM Deployment with Terraform and GitHub Actions

This project uses [Terraform](https://www.terraform.io/) to provision virtual machines on **AWS**, **GCP**, or **Azure**, with a modular and conditional setup via Github Actions.

---

## 🗂️ Project Structure

```bash
.
├── main.tf                 # Root Terraform configuration
├── variables.tf            # Shared variables
├── terraform.tfvars        # User-defined variable values (optional)
├── outputs.tf              # Root outputs
└── modules/
    ├── aws/                # AWS-specific resources
    ├── gcp/                # GCP-specific resources
    └── azure/              # Azure-specific resources
```

---

## 🚀 Supported Cloud Providers

- **Amazon Web Services (AWS)**
- **Google Cloud Platform (GCP)**
- **Microsoft Azure**

Select the provider at deploy time using the `cloud_provider` variable.

---

## 📦 Requirements

- [Terraform ≥ 1.3.0](https://developer.hashicorp.com/terraform/downloads)
- Cloud credentials:
  - AWS: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
  - GCP: Service Account JSON key file
  - Azure: Service principal credentials

---

## ⚙️ Usage

### 1. Clone the Repo

```bash
git clone https://github.com/your-org/multi-cloud-vm-deploy.git
cd multi-cloud-vm-deploy
```

### 2. Choose Cloud and Configure Variables

You can pass variables via:

- `terraform.tfvars`
- CLI flags (`-var=key=value`)
- Environment variables (`TF_VAR_key=value`)

### Example: `terraform.tfvars`
```hcl
cloud_provider        = "AWS"
region                = "us-west-2"
vm_name               = "my-vm"
vm_size               = "t2.micro"
ssh_allowed_ip        = "YOUR_PUBLIC_IP/32"
gcp_credentials       = "path/to/key.json"
gcp_project           = "your-gcp-project"
zone                  = "us-central1-a"
ssh_public_key_path   = "~/.ssh/id_rsa.pub"
azure_client_id       = "xxxxx"
azure_secret          = "xxxxx"
azure_tenant_id       = "xxxxx"
azure_subscription_id = "xxxxx"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Apply the Configuration

```bash
terraform apply -auto-approve
```

Only the selected cloud provider’s module will be used based on `cloud_provider`.

---

## 🔐 SSH Access

- For **AWS**, a new RSA key is generated.
- For **GCP**, a local public key is injected into instance metadata.
- For **Azure**, username and password are defaulted for demo purposes (**replace in production**).

---

## 📤 Outputs

After apply, Terraform outputs the public IP address of the deployed VM.

---

## 🧪 Testing Each Cloud

### AWS
```bash
terraform apply -var="cloud_provider=AWS" -var="region=us-west-2"
```

### GCP
```bash
terraform apply -var="cloud_provider=GCP" -var="region=us-central1"
```

### Azure
```bash
terraform apply -var="cloud_provider=Azure" -var="region=eastus"
```

---

## 🧹 Cleanup

To destroy the deployed resources:

```bash
terraform destroy -auto-approve
```

---

## 📄 License

MIT © 2025 Your Name / Org

---

## 📬 Contributions

Pull requests and issues are welcome!
