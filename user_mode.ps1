# Scoop Installation Script (User Mode)
$logFile = "$env:TEMP\install_log.txt"
Write-Host "Logging installation process to: $logFile"

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Host $message
    Add-Content -Path $logFile -Value $logEntry
}

# Open Notepad to track logs
Start-Process -FilePath "notepad.exe" -ArgumentList $logFile

Write-Log "Checking Scoop installation..."
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Scoop in User Mode..."
    Invoke-WebRequest -Uri https://get.scoop.sh -UseBasicParsing | Invoke-Expression
} else {
    Write-Log "Scoop is already installed."
}

Write-Log "User mode setup complete. Please run the admin script next!"