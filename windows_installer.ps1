# Windows Installer Script using Scoop
Write-Host "Setting Up Required Tools for Windows..."

# Ensure Execution Policy allows running scripts
Set-ExecutionPolicy Bypass -Scope Process -Force

# Install Scoop in Non-Admin User Mode (Recommended)
Write-Host "Checking Scoop installation..."
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop in User Mode..."
    Invoke-WebRequest -Uri https://get.scoop.sh -UseBasicParsing | Invoke-Expression
} else {
    Write-Host "Scoop is already installed."
}

# Enable Admin Mode for Scoop if Running as Administrator
if ($env:USERDOMAIN -eq "NT AUTHORITY") {
    Write-Host "Detected Administrator mode. Switching Scoop to Admin installation..."
    Invoke-WebRequest -Uri https://github.com/ScoopInstaller/Install/raw/master/install.ps1 -UseBasicParsing | Invoke-Expression
    scoop config root "C:\ProgramData\Scoop"
}

# Install Required Software
$packages = @("git", "python", "terraform")
foreach ($pkg in $packages) {
    Write-Host "Installing $pkg..."
    scoop install $pkg
}

# Verify Installation
Write-Host "Verifying installations..."
$failedPackages = @()
foreach ($pkg in $packages) {
    if (!(Get-Command $pkg -ErrorAction SilentlyContinue)) {
        Write-Host "Installation failed for: $pkg"
        $failedPackages += $pkg
    }
}

if ($failedPackages.Count -gt 0) {
    Write-Host "The following packages failed to install: $($failedPackages -join ', ')"
    Exit 1
}

# Fix Python PATH
Write-Host "Updating Python PATH..."
$envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
$pythonPath = "$HOME\scoop\apps\python\current"

# Ensure Python directory exists before updating PATH
if (Test-Path $pythonPath) {
    [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$pythonPath", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Python PATH updated successfully! Restart PowerShell to apply changes."
} else {
    Write-Host "Python directory not found! Verify Python installation."
    Exit 1
}

# Install OpenSSH if missing
Write-Host "Checking OpenSSH installation..."
$openSSH = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH*"
if ($openSSH.Count -eq 0) {
    Write-Host "Installing OpenSSH..."
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host "OpenSSH is already installed."
}

# Start OpenSSH Service
Write-Host "Starting SSH service..."
net start sshd

# Verify Bash is Installed
Write-Host "Checking Bash installation..."
if (!(Get-Command bash -ErrorAction SilentlyContinue)) {
    Write-Host "Bash not found! Install Git Bash or WSL before proceeding."
    Exit 1
}

# Launch Terraform Deployment Script
Write-Host "Launching Terraform Deployment..."
Start-Process -FilePath "bash.exe" -ArgumentList "./deploy_script.sh" -Wait

Write-Host "Setup Complete!"