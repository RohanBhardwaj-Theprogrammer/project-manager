# Check if the file exists in the same directory as the PowerShell script or current directory if running interactively
if (-not (Test-Path (Join-Path (if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }) ".setup_marker"))) {
    # Create the file if it does not exist
  New-Item -Path (Join-Path (if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }) ".setup_marker") -ItemType File -Force | Out-Null
    Write-Host "The file was created."
  . ".\first-time-loader.ps1"
    
    Write-FormattedOutput "Reopen the window now "
    exit
}
# import helpers
. ".\write formated output.ps1"
. ".\OpenFolderinVscode.ps1"
. ".\setting file creation and modifier program.ps1"
. ".\git_worker.ps1"

# retreiving the data from the files
$userdata_main = Get-UserData -FileName "user_data.json"
if (-not $userdata_main) {
  Write-FormattedOutput "No user_data.json found. Run first-time-loader." -Style Red -BackgroundColor White
  return
}

$branch = if ($userdata_main.branch) { $userdata_main.branch } else { 'main' }

#opening the folder in the vscode 
OpenFolderInVsCode -FolderPath $userdata_main.path

if([int]$userdata_main.autopushpull -eq 1){
# Get current time
$currentTime = Get-Date -Format HH:mm

    # Check if it's 12:00 PM
    if ($currentTime -eq "12:00") {
      # Your tasks to run at 12 PM
        try {
          Set-Location -Path $userdata_main.path
          if (Check-Git) {
            git fetch origin 2>&1 | Out-Null
            Write-Host "Pulling updates from GitHub (branch: $branch)..."
            git pull origin $branch
          } else { Write-Warning "Git not available" }
        } catch { Write-Warning "Git pull failed: $($_.Exception.Message)" }

    } 
  if ($currentTime -eq "12:20") {
          Write-FormattedOutput "pushing the changes to the REMOTE SERVER"
     . ".\file size and line of number based git pull file.ps1"
    }

}
