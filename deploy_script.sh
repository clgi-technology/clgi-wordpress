#!/bin/bash

LOG_FILE="terraform_deployment.log"
echo "🌍 Multi-Cloud Deployment Setup" | tee -a $LOG_FILE

# Detect the Operating System
OS_TYPE="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="mac"
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    OS_TYPE="windows"
fi

echo "Detected OS: $OS_TYPE" | tee -a $LOG_FILE

# Clone GitHub Repository Using PAT
GITHUB_USER="your-username"
GITHUB_PAT="${GH_PAT:-your_default_token}"
GITHUB_REPO="your-repo/setup-scripts"

if [ ! -d "setup" ]; then
    git clone https://$GITHUB_USER:$GITHUB_PAT@github.com/$GITHUB_REPO.git setup 2>>$LOG_FILE || {
        echo "❌ GitHub authentication failed! Check your PAT in GitHub Secrets." | tee -a $LOG_FILE
        exit 1
    }
else
    cd setup
    git pull origin main | tee -a $LOG_FILE
    cd ..
fi
echo "✅ GitHub repository updated!" | tee -a $LOG_FILE

# Ask for Deployment Mode
while true; do
    read -p "Enter deployment mode (production/sandbox): " deployment_mode
    if [[ "$deployment_mode" == "production" || "$deployment_mode" == "sandbox" ]]; then
        echo "✅ Deploying in: $deployment_mode mode" | tee -a $LOG_FILE
        break
    else
        echo "❌ Invalid input! Please enter 'production' or 'sandbox'." | tee -a $LOG_FILE
    fi
done

# Initialize Terraform
echo "🚀 Initializing Terraform..." | tee -a $LOG_FILE
terraform init || {
    echo "❌ Terraform initialization failed! Check logs." | tee -a $LOG_FILE
    exit 1
}
terraform validate | tee -a $LOG_FILE

# Deploy Infrastructure
echo "🚀 Deploying Infrastructure..." | tee -a $LOG_FILE
terraform apply -auto-approve || {
    echo "❌ Deployment failed! Retrying Terraform apply..." | tee -a $LOG_FILE
    terraform apply -auto-approve | tee -a $LOG_FILE
}

# Retrieve VM IP
vm_ip=$(terraform output -raw vm_ip)
echo "🔑 Instance Public IP: $vm_ip" | tee -a $LOG_FILE

# Deploy Sandbox (Django Setup)
if [[ "$deployment_mode" == "sandbox" ]]; then
    ssh ubuntu@$vm_ip "pip3 install django requests beautifulsoup4"
    ssh ubuntu@$vm_ip "django-admin startproject sandbox_app /home/ubuntu/sandbox"
    echo "✅ Sandbox environment live! Web Access: http://$vm_ip:8000" | tee -a $LOG_FILE
fi

echo "🎉 Deployment Process Completed Successfully!" | tee -a $LOG_FILE