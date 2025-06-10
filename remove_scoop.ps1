Write-Host "Starting Scoop removal process..."

# Check if Scoop is installed
if (Test-Path "$env:USERPROFILE\scoop") {
    Write-Host "Scoop installation found. Proceeding with removal..."
    
    # Take ownership of Scoop directory
    Write-Host "Forcing ownership of Scoop directory..."
    takeown /F "$env:USERPROFILE\scoop" /R /D Y
    icacls "$env:USERPROFILE\scoop" /grant "%USERNAME%":F /T
    Write-Host "Ownership updated."

    # Stop any running Scoop processes
    Write-Host "Checking for running Scoop processes..."
    $scoopProcesses = Get-Process | Where-Object { $_.ProcessName -match "scoop" }
    if ($scoopProcesses) {
        Write-Host "Stopping Scoop processes..."
        $scoopProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force }
        Write-Host "Scoop processes stopped."
    } else {
        Write-Host "No Scoop processes found."
    }

    # Use Robocopy to empty directory before removal
    Write-Host "Purging Scoop directory using Robocopy..."
    robocopy "$env:USERPROFILE\scoop" "$env:USERPROFILE\scoop_empty" /PURGE
    Write-Host "Scoop directory emptied."

    # Remove Scoop installation directory
    Write-Host "Removing Scoop directory..."
    Remove-Item -Recurse -Force "$env:USERPROFILE\scoop"
    Write-Host "Scoop removed successfully."
} else {
    Write-Host "Scoop not found. Skipping removal."
}

Write-Host "Scoop removal process completed."