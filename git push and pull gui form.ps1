Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Git Task"
$form.Size = New-Object System.Drawing.Size(400, 400)
$form.StartPosition = "Manual"
$form.Location = New-Object System.Drawing.Point(
    ([System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Width - $form.Size.Width),
    ([System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height - $form.Size.Height)
)

# Create a label
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(380, 20)
$label.Text = "Select a Git task:"
$form.Controls.Add($label)

# Function to handle task execution
$executeTask = {
    $selectedTask = $null
    if ($pushButton.Checked) { $selectedTask = "Push to GitHub" }
    elseif ($pullButton.Checked) { $selectedTask = "Pull from GitHub" }
    elseif ($notNowButton.Checked) { $selectedTask = "Not now" }

    try {
        switch ($selectedTask) {
            "Push to GitHub" {
                # Add your Git push command here
                Write-Host "Executing Push to GitHub..." -ForegroundColor Green
                # Example: git push
                Start-Process "git" -ArgumentList "push" -NoNewWindow -Wait
            }
            "Pull from GitHub" {
                # Add your Git pull command here
                Write-Host "Executing Pull from GitHub..." -ForegroundColor Green
                # Example: git pull
                Start-Process "git" -ArgumentList "pull" -NoNewWindow -Wait
            }
            "Not now" {
                Write-Host "No task selected." -ForegroundColor Yellow
            }
            default {
                throw "No valid task selected."
            }
        }
        $form.Close()
    } catch {
        $errorLabel = New-Object System.Windows.Forms.Label
        $errorLabel.Location = New-Object System.Drawing.Point(10, 120)
        $errorLabel.Size = New-Object System.Drawing.Size(380, 40)
        $errorLabel.Text = $_.Exception.Message
        $errorLabel.BackColor = [System.Drawing.Color]::Red
        $errorLabel.ForeColor = [System.Drawing.Color]::White
        $form.Controls.Add($errorLabel)
    }
}

# Create radio buttons (none preselected)
$pushButton = New-Object System.Windows.Forms.RadioButton
$pushButton.Location = New-Object System.Drawing.Point(10, 40)
$pushButton.Size = New-Object System.Drawing.Size(200, 20)
$pushButton.Text = "Push to GitHub"
$pushButton.AutoSize = $true
$pushButton.Add_Click($executeTask)
$form.Controls.Add($pushButton)

$pullButton = New-Object System.Windows.Forms.RadioButton
$pullButton.Location = New-Object System.Drawing.Point(10, 60)
$pullButton.Size = New-Object System.Drawing.Size(200, 20)
$pullButton.Text = "Pull from GitHub"
$pullButton.AutoSize = $true
$pullButton.Add_Click($executeTask)
$form.Controls.Add($pullButton)

$notNowButton = New-Object System.Windows.Forms.RadioButton
$notNowButton.Location = New-Object System.Drawing.Point(10, 80)
$notNowButton.Size = New-Object System.Drawing.Size(200, 20)
$notNowButton.Text = "Not now"
$notNowButton.AutoSize = $true
$notNowButton.Add_Click($executeTask)
$form.Controls.Add($notNowButton)

# Show the form
$form.Topmost = $true
$form.ShowDialog() | Out-Null

Write-Host "closing the file " 
exit

