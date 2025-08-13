<#
Project Manager CLI (pm.ps1)
Unified command entrypoint similar to git/node style.
Usage examples:
  ./pm.ps1 help
  ./pm.ps1 init
  ./pm.ps1 open
  ./pm.ps1 tasks list
  ./pm.ps1 tasks add -name PullNoon -trigger time -time 12:00 -script "git pull origin main" -enable -persist
  ./pm.ps1 tasks run time
#>
param(
  [Parameter(Position=0)] [string]$Command = 'help',
  [Parameter(Position=1)] [string]$SubCommand,
  [string]$Name,
  [string]$Trigger,
  [string]$Time,
  [string]$Script,
  [switch]$Enable,
  [switch]$Persist,
  [string]$Id
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$root/write formated output.ps1"
. "$root/setting file creation and modifier program.ps1"
. "$root/task_automation.ps1"
. "$root/OpenFolderinVscode.ps1"
. "$root/git_worker.ps1"

function Show-Help {
  @"
Project Manager CLI
Commands:
  help                                  Show this help
  init                                  Run first-time loader (interactive)
  open                                  Open project folder in VS Code (from user_data.json)
  git-install                           Check/install Git
  tasks list                            List registered tasks
  tasks add   -name N -trigger T [-time V] -script S [-enable] [-persist]
  tasks enable -id <id>                 Enable a task
  tasks disable -id <id>                Disable a task
  tasks remove -id <id>                 Remove a task
  tasks run <onstart|onclose|time|interval>   Execute matching tasks now
  show-config                           Print current user_data.json
  set-branch <branchName>               Update stored default branch
Examples:
  ./pm.ps1 tasks add -name PullNoon -trigger time -time 12:00 -script "git pull origin main" -enable -persist
  ./pm.ps1 tasks run time
"@ | Write-Host
}

switch ($Command.ToLower()) {
  'help' { Show-Help; return }
  'init' { . "$root/first-time-loader.ps1"; return }
  'open' { $ud = Get-UserData; if($ud){ OpenFolderInVsCode -FolderPath $ud.path }; return }
  'git-install' { Check-Git | Out-Null; return }
  'show-config' { $ud = Get-UserData; if($ud){ $ud | ConvertTo-Json -Depth 6 | Write-Host } else { Write-Host 'No config yet.' }; return }
  'set-branch' { if(-not $SubCommand){ Write-Warning 'Provide branch name: pm.ps1 set-branch main'; return }; $ud = Get-UserData; if($ud){ Edit-UserData -Key 'branch' -NewValue $SubCommand; Write-Host "Branch updated to $SubCommand" } else { Write-Warning 'No config found.' }; return }
  'tasks' {
      switch ($SubCommand) {
        'list' { Get-Tasks | Select-Object Id,Name,Trigger,Time,Enabled | Format-Table | Out-String | Write-Host }
        'add' {
          if(-not $Name -or -not $Trigger -or -not $Script){ Write-Warning 'Missing -Name, -Trigger, or -Script'; break }
          $t = Register-Task -Name $Name -Script $Script -Trigger $Trigger -Time $Time -Enabled:([bool]$Enable.IsPresent) -Persist:([bool]$Persist.IsPresent)
          Write-Host "Task added: $($t.Id) Trigger=$($t.Trigger) Time=$($t.Time)"
        }
        'enable' { if(-not $Id){Write-Warning 'Need -id'} else { Enable-Task -Id $Id; Write-Host 'Enabled.' } }
        'disable' { if(-not $Id){Write-Warning 'Need -id'} else { Disable-Task -Id $Id; Write-Host 'Disabled.' } }
        'remove' { if(-not $Id){Write-Warning 'Need -id'} else { Remove-Task -Id $Id; Write-Host 'Removed.' } }
  'run' { if(-not $Name -and -not $Time -and -not $Trigger -and $SubCommand){ }; if(-not $Name){ Write-Warning 'Specify stage with -Name <onstart|onclose|time|interval>' } else { Invoke-ProjectTasks -TriggerStage $Name } }
        default { Write-Warning 'Unknown tasks subcommand'; Show-Help }
      }
      return
  }
  default { Show-Help }
}
