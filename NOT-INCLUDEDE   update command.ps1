# Configuration
$repoUrl = "https://github.com/YourUsername/YourRepo.git"  # Replace with your GitHub repository URL
$repoPath = "C:\Path\To\Repo"  # Path where the repo will be cloned/updated
$targetPath = "C:\Path\To\Target"  # Path where files will be copied

# Function to ensure directory exists
function Ensure-Directory {
    param (
        [string]$Path
    )
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

# Clone or Update Repository
if (Test-Path -Path $repoPath) {
    Write-Output "Updating repository..."
    Set-Location -Path $repoPath
    git pull origin main
} else {
    Write-Output "Cloning repository..."
    git clone $repoUrl $repoPath
}

# Ensure target directory exists
Ensure-Directory -Path $targetPath

# Function to copy files, excluding specific files
function Copy-Files {
    param (
        [string]$SourcePath,
        [string]$DestinationPath,
        [string]$ExcludeFile
    )

    Get-ChildItem -Path $SourcePath -Recurse | ForEach-Object {
        if ($_.PSIsContainer) {
            # Ensure directory exists in destination
            $destDir = $_.FullName.Replace($SourcePath, $DestinationPath)
            Ensure-Directory -Path $destDir
        } else {
            # Exclude specific file from being copied
            if ($_.Name -ne $ExcludeFile) {
                $destFile = $_.FullName.Replace($SourcePath, $DestinationPath)
                Copy-Item -Path $_.FullName -Destination $destFile -Force
            }
        }
    }
}

# Copy files from repo to target directory
Copy-Files -SourcePath $repoPath -DestinationPath $targetPath -ExcludeFile "mainsrcscrpt.ps1"

Write-Output "Update complete."
