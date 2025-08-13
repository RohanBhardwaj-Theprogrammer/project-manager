function OpenFolderInVsCode {
  param(
    [Parameter(Mandatory = $true)]
    [string] $FolderPath
  )

  if (-not (Test-Path -Path $FolderPath -PathType Container)) {
    Write-Warning "Folder '$FolderPath' not found."
    return
  }

  try {
    Start-Process -FilePath "code" -ArgumentList @("--new-window", $FolderPath) | Out-Null
  } catch {
    Write-Warning "VS Code CLI 'code' not found in PATH. Install VS Code or add 'code' to PATH."
  }
}
