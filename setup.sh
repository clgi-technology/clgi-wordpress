#!/bin/bash

echo "🔄 Initializing Terraform Deployment..."

# Prompt user for environment selection
while true; do
  read -p "Enter Environment (prod/sandbox): " env
  if [[ "$env" == "prod" || "$env" == "sandbox" ]]; then
    break
  else
    echo "❌ Invalid input! Please enter 'prod' or 'sandbox'."
  fi
done

# Prompt user for cloud provider selection
while true; do
  read -p "Enter Cloud Provider (aws/gcp/azure): " provider
  if [[ "$provider" == "aws" || "$provider" == "gcp" || "$provider" == "azure" ]]; then
    break
  else
    echo "❌ Invalid input! Please enter 'aws', 'gcp', or 'azure'."
  fi
done

# Prompt user for database selection
while true; do
  read -p "Select Database (mysql/postgresql): " db
  if [[ "$db" == "mysql" || "$db" == "postgresql" ]]; then
    break
  else
    echo "❌ Invalid input! Please enter 'mysql' or 'postgresql'."
  fi
done

# Prompt user for VM size selection
while true; do
  read -p "Choose VM Size (t3.medium/t3.large): " size
  if [[ "$size" == "t3.medium" || "$size" == "t3.large" ]]; then
    break
  else
    echo "❌ Invalid input! Please enter 't3.medium' or 't3.large'."
  fi
done

# Log user choices
echo "✅ User Input Received:"
echo "   - Environment: $env"
echo "   - Cloud Provider: $provider"
echo "   - Database: $db"
echo "   - VM Size: $size"
echo "   -------------------------------"

# Initialize Terraform
terraform init

# Validate Terraform Configuration
terraform validate

# Apply Terraform with user-defined variables
terraform apply -auto-approve \
  -var="environment=$env" \
  -var="cloud_provider=$provider" \
  -var="database_type=$db" \
  -var="vm_size=$size"

echo "🚀 Terraform Deployment Completed Successfully!"