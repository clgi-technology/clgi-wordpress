# Windows Installer Script (Admin Mode using PuTTY SSH)
$logFile = "$env:TEMP\install_log.txt"
$terraformLogFile = "$HOME\.terraform.d\terraform_debug.log"
Write-Host "Logging installation process to: $logFile"

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Host $message
    Add-Content -Path $logFile -Value $logEntry
}

# Open Notepad to monitor logs in real time
Start-Process -FilePath "notepad.exe" -ArgumentList $logFile

Write-Log "Checking for admin privileges..."
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Log "This script must be run as administrator!"
    Exit 1
}

# Ensure Execution Policy allows running scripts
Set-ExecutionPolicy Bypass -Scope Process -Force

Write-Log "Detected Administrator mode. Proceeding with installation..."
scoop config root "C:\ProgramData\Scoop"

# Enable Developer Mode (Required for Sudo & Symlinks)
Write-Log "Enabling Windows Developer Mode..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Force

# Install Required Software
$packages = @("git", "python", "terraform", "sudo")
foreach ($pkg in $packages) {
    Write-Log "Installing $pkg..."
    scoop install $pkg
}

Write-Log "Verifying installations..."
$failedPackages = @()
foreach ($pkg in $packages) {
    if (!(Get-Command $pkg -ErrorAction SilentlyContinue)) {
        Write-Log "Installation failed for: $pkg"
        $failedPackages += $pkg
    }
}

if ($failedPackages.Count -gt 0) {
    Write-Log ("The following packages failed to install: " + ($failedPackages -join ', '))
    Exit 1
}

# Fix Python PATH
Write-Log "Updating Python PATH..."
$envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
$pythonPath = "$HOME\scoop\apps\python\current"

if (Test-Path $pythonPath) {
    [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$pythonPath", [System.EnvironmentVariableTarget]::Machine)
    Write-Log "Python PATH updated successfully! Restart PowerShell to apply changes."
} else {
    Write-Log "Python directory not found! Verify Python installation."
    Exit 1
}

# Configure PuTTY SSH (Using Manually Installed Version)
Write-Log "Setting up PuTTY for SSH access..."
$puttyPath = "C:\Program Files\PuTTY"

if (!(Test-Path "$puttyPath\putty.exe")) {
    Write-Log "PuTTY installation missing! Verify manual installation."
    Exit 1
}

Write-Log "PuTTY setup complete!"

# Enable Terraform Debug Logging
Write-Log "Enabling Terraform Debug Mode..."
$env:TF_LOG="DEBUG"

# Create Terraform Debug Log Directory
if (!(Test-Path "$HOME\.terraform.d")) {
    New-Item -Path "$HOME\.terraform.d" -ItemType Directory -Force
}
New-Item -Path "$terraformLogFile" -ItemType File -Force

# Launch Terraform Deployment Script with Debugging
Write-Log "Launching Terraform Deployment..."
terraform apply *> $terraformLogFile

# Check for Terraform Errors
if (!(Test-Path $terraformLogFile)) {
    Write-Log "Terraform debug log file missing! Verify logging setup."
    Exit 1
} else {
    Write-Log "Terraform debug log saved: $terraformLogFile"
}

# Wait for Terraform to Complete
Write-Log "Waiting for Terraform to finish..."
Start-Sleep -Seconds 30  # Adjust based on VM creation time

# Fetch the VM’s Assigned IP Dynamically
$vmIpFile = "./vm_ip.txt"
if (Test-Path $vmIpFile) {
    $sshServer = (Get-Content $vmIpFile).Trim()
    Write-Log "Retrieved VM IP: $sshServer"
} else {
    Write-Log "VM IP file not found! Verify Terraform output."
    Exit 1
}

# Verify the VM is Reachable Before SSH Attempt
Write-Log "Checking VM connectivity..."
if (!(Test-NetConnection -ComputerName $sshServer -Port 22).TcpTestSucceeded) {
    Write-Log "VM is unreachable! Check deployment status and network settings."
    Exit 1
}

# Connect to VM via PuTTY SSH
Write-Log "Connecting to VM via SSH..."
Start-Process -FilePath "$puttyPath\putty.exe" -ArgumentList "$sshServer -ssh" -NoNewWindow -Wait

# Verify Bash is Installed
Write-Log "Checking Bash installation..."
if (!(Get-Command bash -ErrorAction SilentlyContinue)) {
    Write-Log "Bash not found! Install Git Bash or WSL before proceeding."
    Exit 1
}

Write-Log "Setup Complete!"