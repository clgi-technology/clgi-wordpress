Write-Host "🌍 Multi-Cloud Deployment Setup"
Write-Host "Fetching latest updates from GitHub..."
git clone https://github.com/your-repo/setup-scripts.git setup
cd setup
git pull origin main
Write-Host "✅ Latest version downloaded!"

Write-Host "Please select a cloud platform: aws, azure, gcp"
$cloudProvider = Read-Host "Enter cloud provider"

Write-Host "🔍 Choose Deployment Mode"
Write-Host "Options: production, sandbox"
$deploymentMode = Read-Host "Enter deployment mode"

# 📩 Ask for email for notifications
Write-Host "🔔 Would you like to receive deployment notifications via email?"
$emailAddress = Read-Host "Enter your email (or leave blank to skip)"

Write-Host "✅ Deploying in: $deploymentMode mode"
terraform init

# Retrieve VM IP from Terraform output
$vmIP = terraform output -raw vm_ip

if ($deploymentMode -eq "sandbox") {
    Write-Host "🚀 Deploying Sandbox Environment with Django..."
    ssh ubuntu@$vmIP "sudo apt update && sudo apt install -y python3 python3-pip mailutils"
    ssh ubuntu@$vmIP "pip3 install django"
    ssh ubuntu@$vmIP "django-admin startproject sandbox_app /home/ubuntu/sandbox"

    # Generate Backup Script
    Write-Host "🔍 Generating automated backup script..."
    ssh ubuntu@$vmIP "echo '#!/bin/bash' > /home/ubuntu/sandbox/auto_backup.sh"
    ssh ubuntu@$vmIP "echo 'python3 manage.py dumpdata > /home/ubuntu/sandbox_backup.json' >> /home/ubuntu/sandbox/auto_backup.sh"
    ssh ubuntu@$vmIP "echo 'tar -czvf /home/ubuntu/sandbox_media_backup.tar.gz /home/ubuntu/sandbox/static' >> /home/ubuntu/sandbox/auto_backup.sh"
    ssh ubuntu@$vmIP "chmod +x /home/ubuntu/sandbox/auto_backup.sh"

    # Schedule Backup
    ssh ubuntu@$vmIP "echo '0 0 * * * /home/ubuntu/sandbox/auto_backup.sh' | crontab -"
    Write-Host "✅ Sandbox auto-backup scheduled every 24 hours!"

    Write-Host "✅ Sandbox environment is live!"
    Write-Host "Web Access: http://$vmIP:8000"

    # Send Email Notification (if provided)
    if ($emailAddress -ne "") {
        Write-Host "📩 Sending notification to $emailAddress"
        ssh ubuntu@$vmIP "echo 'Sandbox Deployment Completed' | mail -s 'Sandbox Ready' $emailAddress"
    }
} elseif ($deploymentMode -eq "production") {
    Write-Host "🚀 Checking for latest sandbox backups..."
    
    $sandboxBackupExists = ssh ubuntu@$vmIP "test -f /home/ubuntu/sandbox_backup.json && echo 'exists'"
    $sandboxMediaExists = ssh ubuntu@$vmIP "test -f /home/ubuntu/sandbox_media_backup.tar.gz && echo 'exists'"

    if ($sandboxBackupExists -or $sandboxMediaExists) {
        Write-Host "🔍 Sandbox changes are available!"
        Write-Host "Would you like to use the latest sandbox modifications for production? [Y/N]"
        $useSandbox = Read-Host "Enter Y or N"

        if ($useSandbox -eq "Y") {
            Write-Host "🚀 Restoring latest sandbox data..."
            ssh ubuntu@$vmIP "python3 manage.py loaddata /home/ubuntu/sandbox_backup.json"
            ssh ubuntu@$vmIP "tar -xzvf /home/ubuntu/sandbox_media_backup.tar.gz -C /home/ubuntu/production/static"
            Write-Host "✅ Sandbox modifications applied to Production!"
        }
    } else {
        Write-Host "✅ No sandbox found, deploying fresh production setup..."
        terraform apply -auto-approve
    }

    Write-Host "🌍 Production environment is live!"

    # Send Email Notification (if provided)
    if ($emailAddress -ne "") {
        Write-Host "📩 Sending notification to $emailAddress"
        ssh ubuntu@$vmIP "echo 'Production Deployment Completed' | mail -s 'Production Ready' $emailAddress"
    }
}