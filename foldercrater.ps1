# Function to create and hide the folder (checks for existing folder)
function Create-HiddenFolder {
  param(
    [string] $Path = "$env:USERPROFILE\Desktop\MyProject",
    [switch] $Hidden
  )

  # Check if folder already exists
  if (Test-Path -Path $Path -PathType Container) {
    Write-Warning "Folder '$($Path.Split('\\')[-1])' already exists. Skipping creation."
    return
  }

  # Create the folder (only if it doesn't exist)
  New-Item -Path $Path -ItemType Directory -Force | Out-Null

  # Set the Hidden attribute conditional
  if ($Hidden.IsPresent) {
    Set-ItemProperty -Path $Path -Name Attributes -Value ((Get-ItemProperty -Path $Path -Name Attributes).Attributes -bor [System.IO.FileAttributes]::Hidden)
  }
  return $Path
}
<#
# Get user input for folder path (optional)
$userInput = Read-Host "Enter a different folder name (or press Enter for 'MyProject'): "

# Check if user provided input, otherwise use default path
if ($userInput) {
  # Basic sanitize: remove invalid path chars
  $sanitized = ([IO.Path]::GetInvalidFileNameChars() | ForEach-Object { [regex]::Escape($_) }) -join '|'
  if ($userInput -match $sanitized) {
    Write-Warning "Folder name contains invalid characters. Using default 'MyProject'."
    $userInput = 'MyProject'
  }
  $pathWithUserInput = Join-Path "$env:USERPROFILE\Desktop" -ChildPath $userInput
  Create-HiddenFolder -Path $pathWithUserInput
} else {
  Create-HiddenFolder  # Use default path
  Write-Host "Folder 'MyProject' created on Desktop and hidden."
}
#>