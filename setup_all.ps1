Write-Host "🌍 Multi-Cloud Deployment Setup"
Write-Host "Please select a cloud platform: aws, azure, gcp"
$cloudProvider = Read-Host "Enter cloud provider"

# Validate cloud input
if ($cloudProvider -ne "aws" -and $cloudProvider -ne "azure" -and $cloudProvider -ne "gcp") {
    Write-Host "❌ Invalid selection! Please rerun and enter 'aws', 'azure', or 'gcp'."
    Exit 1
}

Write-Host "✅ You selected: $cloudProvider"

Write-Host "🔍 Choose Deployment Mode"
Write-Host "Options: production, sandbox"
$deploymentMode = Read-Host "Enter deployment mode"

# Validate input
if ($deploymentMode -ne "production" -and $deploymentMode -ne "sandbox") {
    Write-Host "❌ Invalid selection! Please enter 'production' or 'sandbox'."
    Exit 1
}

Write-Host "✅ Deploying in: $deploymentMode mode"

Write-Host "🔍 Initializing Terraform..."
terraform init

if ($deploymentMode -eq "production") {
    Write-Host "🚀 Checking for latest sandbox backups..."
    $sandboxBackupExists = Test-Path "sandbox_backup.json"
    $sandboxMediaExists = Test-Path "sandbox_media_backup.tar.gz"

    if ($sandboxBackupExists -or $sandboxMediaExists) {
        Write-Host "🔍 Sandbox changes are available!"
        Write-Host "Would you like to use the latest sandbox modifications for production? [Y/N]"
        $useSandbox = Read-Host "Enter Y or N"

        if ($useSandbox -eq "Y") {
            Write-Host "🚀 Restoring latest sandbox data..."
            terraform apply -auto-approve

            $vmIP = terraform output -raw vm_ip
            ssh ubuntu@$vmIP "python3 manage.py loaddata /home/ubuntu/sandbox_backup.json"
            ssh ubuntu@$vmIP "tar -xzvf /home/ubuntu/sandbox_media_backup.tar.gz -C /home/ubuntu/production/static"

            Write-Host "✅ Sandbox modifications applied to Production!"
        }
    } else {
        Write-Host "✅ No sandbox found, deploying fresh production setup..."
        terraform apply -auto-approve
    }

    $vmIP = terraform output -raw vm_ip
    Write-Host "🌍 Production environment is live!"
    Write-Host "Web Access: http://$vmIP"
} else {
    Write-Host "🚀 Deploying Sandbox Environment with Django..."

    # Install Python, Django, and Admin dependencies
    ssh ubuntu@$vmIP "sudo apt update && sudo apt install -y python3 python3-pip"
    ssh ubuntu@$vmIP "pip3 install django"

    # Create Django project
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

        # Move cloned site into Django static folder
        ssh ubuntu@$vmIP "mkdir -p /home/ubuntu/sandbox/static"
        ssh ubuntu@$vmIP "mv /home/ubuntu/sandbox/clgi_clone/* /home/ubuntu/sandbox/static/"

        Write-Host "✅ Website cloned and ready!"
    }

    # Create an admin user for easy content updates
    ssh ubuntu@$vmIP "cd /home/ubuntu/sandbox && python3 manage.py createsuperuser --username admin --email admin@example.com"

    # Schedule automated backups every 24 hours
    ssh ubuntu@$vmIP "echo '0 0 * * * /home/ubuntu/sandbox/auto_backup.sh' | crontab -"

    # Start Django server & serve the site
    ssh ubuntu@$vmIP "cd /home/ubuntu/sandbox && python3 manage.py runserver 0.0.0.0:8000 &"

    Write-Host "✅ Sandbox environment is live!"
    Write-Host "Web Access: http://$vmIP:8000"
    Write-Host "🔑 Admin Panel Access: http://$vmIP:8000/admin"
    Write-Host "Use username 'admin' and your chosen password to log in."
}