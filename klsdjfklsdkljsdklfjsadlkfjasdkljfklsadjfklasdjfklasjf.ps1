function Create-Folder {
    # Prompt for folder name
    $folderName = Read-Host "Enter the desired folder name:"

    # Use .NET's FolderBrowserDialog for user-friendly location selection
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
   if ($dialog.ShowDialog() -eq ([System.Windows.Forms.DialogResult]::OK)) {
        $selectedPath = $dialog.SelectedPath
    } else {
        # Inform user about selecting desktop as default
        Write-Warning "No folder path selected. Defaulting to Desktop."
        $selectedPath = "$env:USERPROFILE\Desktop"
    }

    # Construct full folder path with validation
    $fullPath = "$selectedPath\$folderName"
    if (-not $fullPath.StartsWith("C:\Users\\")) {
        Write-Host "the foler path is :: $fullPath"
        Write-Error "Invalid folder path. Path must start with 'C:\Users\<username>'"
        return # Exit the function if path is invalid
    }

    # Display confirmation message with full path
    Write-Host "Folder name: $folderName"
    Write-Host "Full path: $fullPath"
    $confirmation = Read-Host "Is this location correct? (Y/N):"

    # Proceed only if user confirms
    if ($confirmation -eq "Y") {
        try {
            # Create folder and show success message with path
            New-Item -Path $fullPath -ItemType Directory
            Write-Host "Folder '$folderName' created successfully at '$fullPath'."
        } catch {
            # Handle errors and display error message
            Write-Error "Error creating folder: $($_.Exception.Message)"
        }
    } else {
        # Inform user about aborting
        Write-Host "Folder creation aborted."
    }
}

# Call the function
Create-Folder
