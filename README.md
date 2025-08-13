# Project Manager (PowerShell)

A lightweight Windows PowerShell project bootstrapper/manager that:

- Creates and optionally hides a project folder (default: MyProject on Desktop)
- Stores user settings in `user_data.json`
- Opens the project in VS Code
- Checks/initializes Git and optionally adds a remote
- Provides an optional auto pull/push helper (time-based)

## Prerequisites

- Windows PowerShell 5.1 (default on Windows)
- VS Code installed with the `code` CLI on PATH (Command Palette: "Shell Command: Install 'code' command in PATH")
- Git for Windows installed (script can assist with installation)

## First run

- Right-click and Run with PowerShell, or from a terminal:

```powershell
# From the project folder
powershell -ExecutionPolicy Bypass -File ".\the Main script Runner.ps1"
```

- On first run, you'll be prompted for basic info (name/email/project). The project folder is created at `%USERPROFILE%\Desktop\pine-proke` by default and can be hidden.
- You'll be asked for a Git remote (optional). If provided, it is added as `origin`.

## Configuration

Settings are stored in `user_data.json` in this folder, for example:

```json
{
  "name": "Your Name",
  "email": "you@example.com",
  "hidden": 1,
  "project": "project",
  "folderexists": 1,
  "path": "C:\\Users\\<you>\\Desktop\\MyProject",
  "autopushpull": 0,
  "branch": "main"
}
```

- Set `autopushpull` to 1 to enable timed actions.
- Change `branch` if your repo uses a different default branch.

## Auto pull/push & task automation

- If `autopushpull` is 1 and this main script is running at those times:
  - 12:00 — fetch + pull from `origin <branch>`
  - 12:20 — run the size-based add/commit/push helper

You can also register custom tasks via `task_automation.ps1` (see that file for examples).

To run it in the background on a schedule, create a Windows Task Scheduler job pointing to:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\\path\\to\\the Main script Runner.ps1"
```

## Manual helpers

- Open project in VS Code: rerun the main script or run `OpenFolderinVscode.ps1` and pass the folder.
- Size-based push: run `file size and line of number based git pull file.ps1`.

## Troubleshooting

- If VS Code doesn't open, ensure `code` exists on PATH.
- If Git isn't found, the script will offer to install it; otherwise install from https://git-scm.com/download/win
- If the script is blocked by execution policy, use the Bypass example above.

## Notes

- Scripts are modular and dot-sourced. Do not rename files unless you update import lines.
- This is Windows-only (uses Windows Forms for optional dialogs and Windows paths).

## Step-by-step quick start (friendly usage)
1. Download or clone this repository.
2. Open a PowerShell window in the folder.
3. Run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".\the Main script Runner.ps1"
   ```
4. Answer the prompts (name/email optional; remote URL optional; auto push/pull optional).
5. VS Code opens your project folder; start working.
6. To enable automated pull/push later: edit `user_data.json` and set `"autopushpull": 1`.
7. (Optional) Add custom tasks in `task_automation.ps1` and call `Invoke-ProjectTasks` in a loop or scheduler.

## Unified CLI (pm.ps1)
Instead of dot-sourcing individual scripts, you can use the single entrypoint:
```powershell
./pm.ps1 help
```
Common commands:
```powershell
./pm.ps1 init                   # run first-time setup
./pm.ps1 open                   # open project in VS Code
./pm.ps1 git-install            # check/install Git
./pm.ps1 show-config            # show current config
./pm.ps1 tasks list             # list tasks
./pm.ps1 tasks add -name PullNoon -trigger time -time 12:00 -script "git pull origin main" -enable -persist
./pm.ps1 tasks run -Name time   # execute time-based tasks now
```
View all help:
```powershell
./pm.ps1 help
```

## Task automation usage
Register tasks after dot-sourcing:
```powershell
. .\task_automation.ps1
Register-Task -Name 'DailyPull' -Action { git pull origin main } -Trigger 'time' -Time '09:00' -Enabled
Invoke-ProjectTasks -TriggerStage 'time'
```
Integrate a simple loop (optional):
```powershell
while ($true) {
  Invoke-ProjectTasks -TriggerStage 'time'
  Start-Sleep -Seconds 60
}
```

## Security assessment
Threat surface is minimal (local scripts), but consider:

- Remote URL validation: Only standard HTTPS or SSH Git URLs are accepted.
- Folder name sanitization: Invalid characters are stripped / defaulted.
- No arbitrary command concatenation: User inputs are not directly embedded in unsafe shell strings.
- Git remote addition: Performed only after validation; user can skip.
- Hidden marker `.setup_marker`: Non-sensitive; safe to commit or ignore. Listed in `.gitignore`.
- Logging: Size-push helper writes JSON log only inside the repo; contains file sizes (no code content).

Recommended hardening (optional):
- Run scripts under PowerShell 7 for improved security features.
- Use code signing (`Set-AuthenticodeSignature`) for enterprise distribution.
- Restrict execution policy to `RemoteSigned` after initial setup.
- If enabling encryption later, isolate keys outside repository.

Data stored in `user_data.json`:
```json
{
  "name": "(optional)",
  "email": "(optional)",
  "hidden": 0,
  "project": "project",
  "folderexists": 1,
  "path": "C:/Users/<you>/Desktop/MyProject",
  "autopushpull": 0,
  "branch": "main"
}
```
Avoid committing `user_data.json` (it is ignored by `.gitignore`).

## Contributing
1. Fork the repo
2. Create a feature branch (`feat/task-runner-loop`)
3. Commit with meaningful messages
4. Open a pull request with a clear description

## License
MIT – see `LICENSE`.
