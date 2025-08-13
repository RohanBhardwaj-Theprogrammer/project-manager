<#
Task Automation Utility (restored)
Provides persistent registration and execution of tasks by trigger:
	- onstart, onclose, time (HH:mm), interval (seconds)
Exports: Register-Task, Invoke-ProjectTasks, Get-Tasks, Enable-Task, Disable-Task, Remove-Task
Persistent store: tasks.json alongside this script.
## Example
	Register-Task -Name PullNoon -Script "git pull origin main" -Trigger time -Time 12:00 -Enabled -Persist
	Invoke-ProjectTasks -TriggerStage time
#>

$script:TaskStoreFile = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'tasks.json'
if (-not $script:TaskList) { $script:TaskList = @() }

function Load-Tasks {
	if (Test-Path $script:TaskStoreFile) {
		try {
			$raw = Get-Content $script:TaskStoreFile -Raw
			if ($raw) {
				$arr = $raw | ConvertFrom-Json
				$script:TaskList = @()
				foreach ($t in $arr) {
					if (-not $t.Script) { continue }
					$sb = [scriptblock]::Create($t.Script)
						$script:TaskList += [PSCustomObject]@{
							Id      = $t.Id
							Name    = $t.Name
							Action  = $sb
							Script  = $t.Script
							Trigger = $t.Trigger
							Time    = $t.Time
							Enabled = [bool]$t.Enabled
						}
				}
			}
		} catch { Write-Warning "Failed to load tasks: $($_.Exception.Message)" }
	}
}

function Save-Tasks {
	try {
		$export = $script:TaskList | ForEach-Object { [PSCustomObject]@{ Id=$_.Id; Name=$_.Name; Trigger=$_.Trigger; Time=$_.Time; Enabled=$_.Enabled; Script=$_.Script } }
		($export | ConvertTo-Json -Depth 6) | Set-Content -Path $script:TaskStoreFile -Encoding UTF8
	} catch { Write-Warning "Failed to save tasks: $($_.Exception.Message)" }
}

Load-Tasks

function Register-Task {
	param(
		[Parameter(Mandatory)] [string]$Name,
		[Parameter(Mandatory)] [string]$Script,
		[ValidateSet('onstart','onclose','time','interval')] [string]$Trigger = 'onstart',
		[string]$Time,
		[switch]$Enabled,
		[switch]$Persist
	)
	if ($Trigger -in 'time' -and -not $Time) { throw "Time trigger requires -Time HH:mm" }
	if ($Trigger -eq 'interval' -and -not $Time) { throw "Interval trigger requires -Time <seconds>" }
	$task = [PSCustomObject]@{
		Id      = [guid]::NewGuid().ToString()
		Name    = $Name
		Action  = [scriptblock]::Create($Script)
		Script  = $Script
		Trigger = $Trigger
		Time    = $Time
		Enabled = $Enabled.IsPresent
	}
	$script:TaskList += $task
	if ($Persist) { Save-Tasks }
	return $task
}

function Get-Tasks { $script:TaskList }
function Enable-Task { param([Parameter(Mandatory)][string]$Id) ($script:TaskList | Where-Object Id -eq $Id).Enabled = $true; Save-Tasks }
function Disable-Task { param([Parameter(Mandatory)][string]$Id) ($script:TaskList | Where-Object Id -eq $Id).Enabled = $false; Save-Tasks }
function Remove-Task { param([Parameter(Mandatory)][string]$Id) $script:TaskList = $script:TaskList | Where-Object Id -ne $Id; Save-Tasks }

function Invoke-ProjectTasks {
	param([Parameter(Mandatory)][ValidateSet('onstart','onclose','time','interval')] [string]$TriggerStage)
	$now = Get-Date -Format HH:mm
	foreach ($t in $script:TaskList) {
		if (-not $t.Enabled) { continue }
		switch ($t.Trigger) {
			'onstart' { if ($TriggerStage -eq 'onstart') { & $t.Action } }
			'onclose' { if ($TriggerStage -eq 'onclose') { & $t.Action } }
			'time'    { if ($TriggerStage -eq 'time' -and $t.Time -eq $now) { & $t.Action } }
			'interval'{ if ($TriggerStage -eq 'interval') { Start-Sleep -Seconds ([int]$t.Time); & $t.Action } }
		}
	}
}

Export-ModuleMember -Function Register-Task,Invoke-ProjectTasks,Get-Tasks,Enable-Task,Disable-Task,Remove-Task,Save-Tasks,Load-Tasks

# End of task automation module
