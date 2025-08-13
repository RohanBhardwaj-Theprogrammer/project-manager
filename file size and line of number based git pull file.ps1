# Define variables

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\setting file creation and modifier program.ps1"
. "$here\git_worker.ps1"
$user = Get-UserData -FileName 'user_data.json'
if (-not $user) { Write-Warning "user_data.json missing"; return }
$repoPath = $user.path
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile = Join-Path -Path $scriptDirectory -ChildPath "js fetch logs of files.json"  # Log file in the script directory
$thresholdPercentage = 140
$largeFileThreshold = 5MB -as [long]
$largeFileThresholdPercentage = 120

# Function to get file size in bytes
function Get-FileSize {
  param ($filePath)
  try {
    return (Get-Item $filePath).Length
  } catch {
    Write-Error "Error getting size for file: $filePath. Error: $_"
    return 0
  }
}

# Function to check file size changes
function Check-FileSizeChanges {
  param ($filePath, $lastSize)
  $currentSize = Get-FileSize -filePath $filePath
  if ($lastSize -eq 0) {
    return $true
  }
  $sizeChange = (($currentSize - $lastSize) / $lastSize) * 100
  if (($currentSize -gt $largeFileThreshold -and $sizeChange -ge $largeFileThresholdPercentage) -or
      ($sizeChange -ge $thresholdPercentage)) {
    return $true
  }
  return $false
}

# Function to handle Git operations with error handling
function Handle-GitOperation {
  param ($gitCommand)
  try {
    $output = & git $gitCommand 2>&1
    if ($LASTEXITCODE -ne 0) {
      Write-Error "Git command failed: $gitCommand. Output: $output"
      return $false
    }
    return $true
  } catch {
    Write-Error "Error executing Git command: $gitCommand. Error: $_"
    return $false
  }
}

# Main script
try {
  Set-Location -Path $repoPath

  # Initialize log file if it does not exist
  if (-not (Test-Path -Path $logFile)) {
    try {
      New-Item -Path $logFile -ItemType File -Force | Out-Null
    } catch {
      Write-Error "Error creating log file. Error: $_"
      exit 1
    }
  }

  # Get list of files in repo
  try {
    $files = Get-ChildItem -Path $repoPath -Recurse -File
  } catch {
    Write-Error "Error retrieving file list. Error: $_"
    return
  }

  $filesToPush = @()
  $currentPushDetails = @{}

  foreach ($file in $files) {
    $filePath = $file.FullName
    $lastSize = 0 # Assuming no previous size information for initial run

    # Read last push details from the log file (optional)
    if (Test-Path -Path $logFile) {
      try {
        $lastPushDetails = Get-Content -Path $logFile | ConvertFrom-Json
        if ($lastPushDetails -ne $null -and $lastPushDetails.ContainsKey($filePath)) {
          $lastSize = $lastPushDetails[$filePath]
        }
      } catch {
        Write-Error "Error reading log file. Error: $_"
      }
    }

    if (Check-FileSizeChanges -filePath $filePath -lastSize $lastSize) {
      $filesToPush += $filePath
    }

    # Update last size for future checks (optional)
    $currentPushDetails[$filePath] = Get-FileSize -filePath $filePath
  }

  # Push changes if any files meet the criteria
  if ($filesToPush.Count -gt 0) {
    try {
      # Add and commit the changes before pushing
      if (Handle-GitOperation -gitCommand "add .") {
        if (Handle-GitOperation -gitCommand "commit -m 'Automated commit'") {
          $branch = if ($user.branch) { $user.branch } else { 'main' }
          if (Handle-GitOperation -gitCommand "push origin $branch") {
            # Update log file with current push details (optional)
            ($currentPushDetails | ConvertTo-Json -Depth 5) | Set-Content -Path $logFile -Encoding UTF8
            Write-Host "Successfully pushed changes to remote server!"
          }
        }
      }
    } catch {
      Write-Error "Error during Git push operation. Error: $_"
    }
  } else {
    Write-Host "No significant file size changes detected."
  }

} catch {
  Write-Error "Unhandled error: $_"
  exit 1
}
