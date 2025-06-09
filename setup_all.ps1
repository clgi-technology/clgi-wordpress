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

Write-Host "✅ Deploying in: $deploymentMode mode"
terraform init

if ($deploymentMode -eq "sandbox") {
    Write-Host "🚀 Deploying Sandbox Environment with Django..."
    ssh ubuntu@$vmIP "sudo apt update && sudo apt install -y python3 python3-pip"
    ssh ubuntu@$vmIP "pip3 install django"
    ssh ubuntu@$vmIP "django-admin startproject sandbox_app /home/ubuntu/sandbox"

    Write-Host "🔍 Clone an existing website? [Y/N]"
    $cloneChoice = Read-Host "Enter Y or N"

    if ($cloneChoice -eq "Y") {
        Write-Host "Enter website URL to clone or press Enter to use www.clgi.org"
        $websiteURL = Read-Host "Website URL"

        if ($websiteURL -eq "") {
            $websiteURL = "https://www.clgi.org"
        }

        Write-Host "🚀 Cloning website: $websiteURL"
        ssh ubuntu@$vmIP "pip3 install requests beautifulsoup4"
        ssh ubuntu@$vmIP "python3 /home/ubuntu/sandbox/clone_site.py $websiteURL"

        ssh ubuntu@$vmIP "mkdir -p /home/ubuntu/sandbox/static"
        ssh ubuntu@$vmIP "mv /home/ubuntu/sandbox/clgi_clone/* /home/ubuntu/sandbox/static/"

        Write-Host "✅ Website cloned and ready!"
    }

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
    Write-Host "🔑 Admin Panel Access: http://$vmIP:8000/admin"
    Write-Host "Use username 'admin' and your chosen password to log in."
} elseif ($deploymentMode -eq "production") {
    Write-Host "🚀 Checking for latest sandbox backups..."
    $sandboxBackupExists = Test-Path "sandbox_backup.json"
    $sandboxMediaExists = Test-Path "sandbox_media_backup.tar.gz"

    if ($sandboxBackupExists -or $sandboxMediaExists) {
        Write-Host "🔍 Sandbox changes are available!"
        Write-Host "Would you like to use the latest sandbox modifications for production? [Y/N]"
        $useSandbox = Read-Host "Enter Y or N"

        if ($useSandbox -eq "Y") {
            Write-Host "🚀 Restoring latest sandbox data..."
            
            # Generate Restore Script
            ssh ubuntu@$vmIP "echo '#!/bin/bash' > /home/ubuntu/restore_sandbox.sh"
            ssh ubuntu@$vmIP "echo 'python3 manage.py loaddata /home/ubuntu/sandbox_backup.json' >> /home/ubuntu/restore_sandbox.sh"
            ssh ubuntu@$vmIP "echo 'tar -xzvf /home/ubuntu/sandbox_media_backup.tar.gz -C /home/ubuntu/production/static' >> /home/ubuntu/restore_sandbox.sh"
            ssh ubuntu@$vmIP "chmod +x /home/ubuntu/restore_sandbox.sh"

            # Run Restore Script
            ssh ubuntu@$vmIP "/home/ubuntu/restore_sandbox.sh"
            Write-Host "✅ Sandbox modifications applied to Production!"
        }
    } else {
        Write-Host "✅ No sandbox found, deploying fresh production setup..."
        terraform apply -auto-approve
    }

    $vmIP = terraform output -raw vm_ip
    Write-Host "🌍 Production environment is live!"
    Write-Host "Web Access: http://$vmIP"
}