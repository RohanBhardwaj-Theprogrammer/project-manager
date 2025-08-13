. ".\write formated output.ps1" # output formatting
. ".\setting file creation and modifier program.ps1" # file utilities
. ".\git_worker.ps1" # git utilities
. ".\foldercrater.ps1" # create project folder


#cheking if the folder  is there or not 
if(-not (Test-FileInCurrentDirectory "user_data.json")){
    ## creatin the user data file
    Create-JsonFile "user_data.json"
    ## default values
  $data = "YourName", "you@example.com","project",1
    Write-FormattedOutput "It will be done only one time " 
    Write-Host ""
    ## asking the data from the user
    $name = Read-Host "Enter your Name : "
    $email = Read-Host "Enter you Email: "
    $hidden = Read-Host "Do you want to hide this project from others (1/0) : "
  $prj = Read-Host "Do you want to name this project or Press ENTER to SKIP"
  Write-FormattedOutput "Enable auto push/pull? 1=yes, 0=no (default 0)"
  $pushpull = Read-Host "Auto push/pull (1/0):"
  # $encryption = Read-Host "Do you want to encrypt and decrypt the files (1 for yes) or Enter to skip: "

    ## makig the array of the data 
  $userData = @{
    name         = ChooseValue -Value1 $name -Value2 (Get-SystemAndMacAddress)
    email        = ChooseValue -Value1 $email -Value2 $data[1]
    hidden       = [int](ChooseValue -Value1 $hidden -Value2 1)
    project      = ChooseValue -Value1 $prj -Value2 $data[2]
    folderexists = 0
  path         = "$env:USERPROFILE\Desktop\MyProject"
    autopushpull = [int](ChooseValue -Value1 $pushpull -Value2 0)
    branch       = 'main'
    # encryption = [int](ChooseValue -Value1 $encryption -Value2 0)
  }

    Set-UserData -Data $userData
}


function Get-SystemAndMacAddress {
  $userName = $env:UserName
  $computer = $env:COMPUTERNAME
  $macs = (Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Up'}).PhysicalAddress -join ','
  return "$computer/$userName - $macs"
}

# Validate remote Git URL to reduce risk of malformed command injection
function Validate-RemoteUrl {
  param([string]$Url)
  if ([string]::IsNullOrWhiteSpace($Url)) { return $false }
  # Allow typical HTTPS or SSH patterns (GitHub/GitLab/Bitbucket style)
  $patterns = @(
    '^https://[A-Za-z0-9_.-]+/(?:[A-Za-z0-9_.-]+/){1}[A-Za-z0-9_.-]+(?:\.git)?/?$',
    '^git@[A-Za-z0-9_.-]+:[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(?:\.git)?$'
  )
  foreach ($p in $patterns) { if ($Url -match $p) { return $true } }
  return $false
}
function ChooseValue {
  param(
    [Parameter(Mandatory = $true)]
    [object] $Value1,  # First variable to check
    [object] $Value2  # Second variable to be chosen if Value1 is empty
  )

  if ([string]::IsNullOrEmpty($Value1)) {
    return $Value2
  } else {
    return $Value1
  }
}



##-------------------------------------------------------------------------
# When the file already exists
$filecontent = Get-UserData -FileName "user_data.json"
if ($filecontent) {
  if([int]$filecontent.folderexists -eq 0){
    Create-HiddenFolder -Path $filecontent.path -Hidden:$([bool]([int]$filecontent.hidden)) | Out-Null
    Edit-UserData -Key "folderexists" -NewValue 1
  }

  # Check Git
  [void](Check-Git)

  function Test-PythonInstalled {
    try { Get-Command python -ErrorAction Stop | Out-Null; return $true } catch { return $false }
  }
  if (Test-PythonInstalled) {
    Write-FormattedOutput "Python is installed."
    Write-FormattedOutput "You can install optional packages later if needed."
    # Optional installs (commented to avoid long-running operations):
    # python -m pip install --upgrade pip
    # python -m pip install scikit-learn matplotlib scipy jupyter seaborn
  } else {
    Write-FormattedOutput "Python is not installed."
  }

  $directory = $filecontent.path
  if (Test-Path (Join-Path $directory ".git")) {
    Write-Host "Git is initialized in the specified directory."
  } else {
    Write-FormattedOutput "Initializing Git in the project directory"
    Set-Location -Path $filecontent.path
    git init
    git config user.name "$($filecontent.name)"
    git config user.email "$($filecontent.email)"

    $remoteUrl = Read-Host "Enter the Git remote URL (https or git@; Enter to skip)"
    if (-not [string]::IsNullOrWhiteSpace($remoteUrl)) {
      if (Validate-RemoteUrl -Url $remoteUrl) {
        git remote add origin $remoteUrl
        Write-FormattedOutput "Remote 'origin' added."
      } else {
        Write-Warning "Remote URL failed validation and was not added."
      }
    }
  }
}

