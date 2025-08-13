<#
Utility functions for reading/writing a JSON settings file (default: user_data.json)
and some common helpers used by other scripts.
#>

# Return the directory of the current script (works in ISE and console)
function Get-ScriptDirectory {
    if ($PSScriptRoot) { return $PSScriptRoot }
    return Split-Path -Parent $MyInvocation.MyCommand.Path
}

# Read user data JSON into a PowerShell object. Returns $null if missing/invalid.
function Get-UserData {
    param(
        [string] $FileName = 'user_data.json'
    )

    $scriptDirectory = Get-ScriptDirectory
    $filePath = Join-Path $scriptDirectory $FileName

    if (-not (Test-Path $filePath)) {
        Write-Verbose "User data file not found: $filePath"
        return $null
    }

    try {
        $content = Get-Content $filePath -Raw
        if (-not [string]::IsNullOrWhiteSpace($content)) {
            return $content | ConvertFrom-Json
        }
        return $null
    } catch {
        Write-Warning "Failed to read '$filePath': $($_.Exception.Message)"
        return $null
    }
}

# Write hashtable/object to user data JSON.
function Set-UserData {
    param(
        [Parameter(Mandatory=$true)]
        [object] $Data,
        [string] $FileName = 'user_data.json'
    )

    $scriptDirectory = Get-ScriptDirectory
    $filePath = Join-Path $scriptDirectory $FileName

    try {
        $jsonData = $Data | ConvertTo-Json -Depth 10
        # Windows PowerShell 5.1: UTF8 will include BOM. That's fine for JSON.
        Set-Content -Path $filePath -Value $jsonData -Encoding UTF8
        Write-Verbose "User data written to '$filePath'"
    } catch {
        Write-Error "Error writing user data to '$filePath': $($_.Exception.Message)"
        throw
    }
}

# Merge new keys into existing user data and save
function Add-UserData {
    param(
        [Parameter(Mandatory=$true)] [hashtable] $NewData,
        [string] $FileName = 'user_data.json'
    )

    $userData = Get-UserData -FileName $FileName
    if (-not $userData) { $userData = @{} }
    foreach ($k in $NewData.Keys) { $userData[$k] = $NewData[$k] }
    Set-UserData -Data $userData -FileName $FileName
}

# Update a single key
function Edit-UserData {
    param(
        [Parameter(Mandatory=$true)] [string] $Key,
        [Parameter(Mandatory=$true)] [object] $NewValue,
        [string] $FileName = 'user_data.json'
    )

    $userData = Get-UserData -FileName $FileName
    if (-not $userData) { $userData = @{} }
    $userData[$Key] = $NewValue
    Set-UserData -Data $userData -FileName $FileName
}

# Create empty JSON file if not exists
function Create-JsonFile {
    param(
        [Parameter(Mandatory = $true)] [string] $FileName
    )
    $scriptDirectory = Get-ScriptDirectory
    $filePath = Join-Path $scriptDirectory $FileName
    if (Test-Path $filePath) {
        Write-Verbose "File already exists: $filePath"
        return
    }
    try {
        New-Item -Path $filePath -ItemType File -Force | Out-Null
    } catch {
        Write-Error "Error creating JSON file '$filePath': $($_.Exception.Message)"
        throw
    }
}

# Check if a file exists next to this script
function Test-FileInCurrentDirectory {
    param(
        [Parameter(Mandatory = $true)] [string] $FileName
    )
    $scriptDirectory = Get-ScriptDirectory
    $filePath = Join-Path $scriptDirectory $FileName
    return Test-Path -Path $filePath -PathType Leaf
}

# Ensure a directory exists
function Ensure-Directory {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path -Path $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
    return $Path
}
