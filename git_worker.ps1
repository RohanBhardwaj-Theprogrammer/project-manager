function Get-GitVersion {
  try { return (& git --version) } catch { return $null }
}

# Check if Git is available; optionally prompt install.
function Check-Git {
  try {
    $cmd = Get-Command git -ErrorAction Stop
    if ($null -ne $cmd) { return $true }
  } catch { }

  Write-FormattedOutput "Git is not installed. Install now? (Y/N)" -Style Red -BackgroundColor White
  $confirmInstall = Read-Host
  if ($confirmInstall -match '^(Y|y)') {
    $downloadUrl = "https://github.com/git-for-windows/git/releases/latest/download/Git-2.45.2-64-bit.exe"
    $installerPath = Join-Path $env:TEMP "Git-Setup.exe"
    try {
      Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath
      Start-Process -FilePath $installerPath -Wait -ArgumentList "/VERYSILENT /NORESTART"
      return $true
    } catch {
      Write-Error "Error installing Git: $($_.Exception.Message)"
      return $false
    }
  } else {
    Write-Warning "Git is required for Git-related features."
    return $false
  }
}

