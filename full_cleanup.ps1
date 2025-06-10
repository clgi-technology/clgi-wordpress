# Check if PowerShell is running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'."
    Exit 1
}

Write-Host "Starting Full Cleanup for Windows..."

# Stop any running Terraform processes
Write-Host "Checking for running Terraform processes..."
$terraformProcesses = Get-Process | Where-Object { $_.ProcessName -match "terraform" }
if ($terraformProcesses) {
    Write-Host "Stopping Terraform processes..."
    $terraformProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force }
    Write-Host "Terraform processes stopped."
} else {
    Write-Host "No Terraform processes found."
}

# Comment out AWS credential variables in Terraform files
Write-Host "Commenting out AWS credentials in main.tf..."
(Get-Content "main.tf") -replace '^\s*access_key\s*=', '# access_key =' `
                         -replace '^\s*secret_key\s*=', '# secret_key =' | Set-Content "main.tf"
Write-Host "AWS credential references commented out."

# Remove Terraform state files
Write-Host "Cleaning up Terraform state files..."
Remove-Item -Recurse -Force .terraform, terraform.tfstate, terraform.tfstate.backup -ErrorAction SilentlyContinue
Write-Host "Terraform files removed."

# Call separate Scoop cleanup script
Write-Host "Calling Scoop removal script..."
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File .\remove_scoop.ps1" -Wait
Write-Host "Scoop removal process completed."

# Remove AWS credentials
Write-Host "Unsetting AWS credentials..."
[System.Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "", [System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "", [System.EnvironmentVariableTarget]::Process)

Write-Host "AWS credentials removed from environment variables."

# Remove cloned repository
Write-Host "Removing cloned setup repository..."
Remove-Item -Recurse -Force setup -ErrorAction SilentlyContinue
Write-Host "Setup repository deleted."

Write-Host "Full Windows Cleanup Completed."