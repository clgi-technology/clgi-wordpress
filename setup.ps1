# Set log file path
$logFile = "terraform_deployment.log"
"Multi-Cloud Deployment Setup" | Tee-Object -FilePath $logFile -Append

# Scoop installation (if needed)
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop not found. Installing..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-Expression (Invoke-WebRequest -UseBasicParsing "https://get.scoop.sh").Content
    Write-Host "Scoop installed."
} else {
    Write-Host "Scoop already installed."
}

# Install required tools
$tools = @("terraform", "git", "python")
foreach ($tool in $tools) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $tool..."
        scoop install $tool
    } else {
        Write-Host "$tool already installed."
    }
}

# Restore AWS credential blocks in main.tf
Write-Host "Restoring AWS credentials in Terraform configuration..."
(Get-Content main.tf) -replace '# access_key =', 'access_key =' |
    ForEach-Object { $_ -replace '# secret_key =', 'secret_key =' } |
    Set-Content main.tf
Write-Host "AWS credentials uncommented."

# Set AWS region
$awsRegion = "us-east-2"
$env:TF_VAR_region = $awsRegion
Write-Host "AWS region set to: $awsRegion"

# Optional GCP project input
$gcpProject = Read-Host "Enter GCP Project ID (press Enter to skip)"
if ([string]::IsNullOrWhiteSpace($gcpProject)) {
    $env:TF_VAR_gcp_project = ""
    Write-Host "GCP project ID skipped."
} else {
    $env:TF_VAR_gcp_project = $gcpProject
    Write-Host "GCP project ID set to: $gcpProject"
}

# Initialize Terraform
Write-Host "Initializing Terraform..."
terraform init 2>&1 | Tee-Object -FilePath $logFile -Append
if ($LASTEXITCODE -ne 0) {
    Write-Host "Terraform initialization failed. Check log."
    exit 1
}
Write-Host "Terraform initialized."

# Validate Terraform config
Write-Host "Validating Terraform configuration..."
terraform validate 2>&1 | Tee-Object -FilePath $logFile -Append
if ($LASTEXITCODE -ne 0) {
    Write-Host "Terraform validation failed. Check log."
    exit 1
}

# Apply Terraform with retry loop
$retryCount = 0
$maxRetries = 3
while ($retryCount -lt $maxRetries) {
    terraform apply -auto-approve 2>&1 | Tee-Object -FilePath $logFile -Append
    if ($LASTEXITCODE -eq 0) { break }
    $retryCount++
    Write-Host "Deployment failed. Retrying ($retryCount/$maxRetries)..."
    Start-Sleep -Seconds 10
}
if ($retryCount -eq $maxRetries) {
    Write-Host "Deployment failed after retries."
    exit 1
}

# Output VM IP
$vmIp = terraform output -raw vm_ip
"Instance Public IP: $vmIp" | Tee-Object -FilePath $logFile -Append

"Deployment Process Completed Successfully." | Tee-Object -FilePath $logFile -Append