#!/bin/bash

LOG_FILE="terraform_deployment.log"

echo "🔄 Initializing Terraform Deployment..." | tee -a $LOG_FILE

# Prompt user for environment selection
while true; do
  read -p "Enter Environment (prod/sandbox): " env
  if [[ "$env" == "prod" || "$env" == "sandbox" ]]; then
    echo "✅ Environment selected: $env" | tee -a $LOG_FILE
    break
  else
    echo "❌ Invalid input! Please enter 'prod' or 'sandbox'." | tee -a $LOG_FILE
  fi
done

# Prompt user for cloud provider selection
while true; do
  read -p "Enter Cloud Provider (aws/gcp/azure): " provider
  if [[ "$provider" == "aws" || "$provider" == "gcp" || "$provider" == "azure" ]]; then
    echo "✅ Cloud provider selected: $provider" | tee -a $LOG_FILE
    break
  else
    echo "❌ Invalid input! Please enter 'aws', 'gcp', or 'azure'." | tee -a $LOG_FILE
  fi
done

# Prompt user for region selection
while true; do
  read -p "Enter Region (e.g., us-east-1, europe-west1, eastus): " region
  if [[ ! -z "$region" ]]; then
    echo "✅ Region selected: $region" | tee -a $LOG_FILE
    break
  else
    echo "❌ Invalid input! Please enter a valid region." | tee -a $LOG_FILE
  fi
done

# Prompt user for VM size selection
while true; do
  read -p "Choose VM Size (t3.medium/t3.large): " size
  if [[ "$size" == "t3.medium" || "$size" == "t3.large" ]]; then
    echo "✅ VM size selected: $size" | tee -a $LOG_FILE
    break
  else
    echo "❌ Invalid input! Please enter 't3.medium' or 't3.large'." | tee -a $LOG_FILE
  fi
done

# Prompt user for database selection
while true; do
  read -p "Select Database (mysql/postgresql): " db
  if [[ "$db" == "mysql" || "$db" == "postgresql" ]]; then
    echo "✅ Database selected: $db" | tee -a $LOG_FILE
    break
  else
    echo "❌ Invalid input! Please enter 'mysql' or 'postgresql'." | tee -a $LOG_FILE
  fi
done

# Prompt user for GCP Project ID
while true; do
  read -p "Enter GCP Project ID: " gcp_project
  if [[ ! -z "$gcp_project" ]]; then
    echo "✅ GCP Project ID entered: $gcp_project" | tee -a $LOG_FILE
    break
  else
    echo "❌ Invalid input! Please enter a valid GCP Project ID." | tee -a $LOG_FILE
  fi
done

# Prompt user for GCP Credentials Path
while true; do
  read -p "Enter GCP Credentials Path (e.g., /secrets/gcp.json): " gcp_credentials
  if [[ ! -z "$gcp_credentials" ]]; then
    echo "✅ GCP Credentials Path entered: $gcp_credentials" | tee -a $LOG_FILE
    break
  else
    echo "❌ Invalid input! Please enter a valid path." | tee -a $LOG_FILE
  fi
done

# Log user choices
echo "✅ User Input Summary:" | tee -a $LOG_FILE
echo "   - Environment: $env" | tee -a $LOG_FILE
echo "   - Cloud Provider: $provider" | tee -a $LOG_FILE
echo "   - Region: $region" | tee -a $LOG_FILE
echo "   - VM Size: $size" | tee -a $LOG_FILE
echo "   - Database Type: $db" | tee -a $LOG_FILE
echo "   - GCP Project ID: $gcp_project" | tee -a $LOG_FILE
echo "   - GCP Credentials Path: $gcp_credentials" | tee -a $LOG_FILE
echo "   -------------------------------" | tee -a $LOG_FILE

# Initialize Terraform
terraform init | tee -a $LOG_FILE

# Validate Terraform Configuration
terraform validate | tee -a $LOG_FILE

# Apply Terraform with user-defined variables, capturing errors
echo "🚀 Deploying Infrastructure..." | tee -a $LOG_FILE
terraform apply -auto-approve \
  -var="environment=$env" \
  -var="cloud_provider=$provider" \
  -var="region=$region" \
  -var="vm_size=$size" \
  -var="database_type=$db" \
  -var="gcp_project=$gcp_project" \
  -var="gcp_credentials_path=$gcp_credentials" 2>&1 | tee -a $LOG_FILE

# Check if deployment failed
if grep -q "Error" $LOG_FILE; then
  echo "❌ Deployment failed! Running rollback..." | tee -a $LOG_FILE
  terraform destroy -auto-approve | tee -a $LOG_FILE
  echo "🔄 Retrying deployment..." | tee -a $LOG_FILE
  terraform apply -auto-approve \
    -var="environment=$env" \
    -var="cloud_provider=$provider" \
    -var="region=$region" \
    -var="vm_size=$size" \
    -var="database_type=$db" \
    -var="gcp_project=$gcp_project" \
    -var="gcp_credentials_path=$gcp_credentials" | tee -a $LOG_FILE
else
  echo "✅ Deployment succeeded!" | tee -a $LOG_FILE
fi