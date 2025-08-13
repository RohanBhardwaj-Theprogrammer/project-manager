function Write-FormattedOutput {
  param(
    [Parameter(Mandatory = $true)]
    [string] $Message,
    [string] $Style = "Green",  # Default style (Green text)
    [string] $BackgroundColor = "DarkGray"  # Default background (DarkGray)
  )

  # Validate styles
  $validColors = @("Red", "Green", "Yellow", "Cyan", "Magenta", "White", "DarkGray", "Blue")
  if ($Style -notin $validColors) {
    # fall back silently
    $Style = "Green"
  }

  if ($BackgroundColor -notin $validColors) {
    # fall back silently
    $BackgroundColor = "DarkGray"
  }

  # Apply color style (if specified)
  $foregroundColor = switch ($Style) {
    "Red"    { [System.ConsoleColor]::Red }
    "Green"  { [System.ConsoleColor]::Green }
    "Yellow" { [System.ConsoleColor]::Yellow }
    "Cyan"   { [System.ConsoleColor]::Cyan }
    "Magenta"{ [System.ConsoleColor]::Magenta }
    "White"  { [System.ConsoleColor]::White }
    "DarkGray" { [System.ConsoleColor]::DarkGray }
    "Blue"   { [System.ConsoleColor]::Blue }
    default  { [System.ConsoleColor]::Green }  # Default to Green
  }

  # Apply background color (if specified)
  $backgroundColor = switch ($BackgroundColor) {
    "Red"    { [System.ConsoleColor]::Red }
    "Green"  { [System.ConsoleColor]::Green }
    "Yellow" { [System.ConsoleColor]::Yellow }
    "Cyan"   { [System.ConsoleColor]::Cyan }
    "Magenta"{ [System.ConsoleColor]::Magenta }
    "White"  { [System.ConsoleColor]::White }
    "DarkGray" { [System.ConsoleColor]::DarkGray }
    "Blue"   { [System.ConsoleColor]::Blue }
    default  { [System.ConsoleColor]::DarkGray }  # Default to DarkGray
  }

  # Create a padding of four tabs
  $tabPadding = "`t`t`t`t"

  # Combine tab padding with the message
  $formattedMessage = $tabPadding + $Message

  # Use Write-Host with foreground and background colors
  if ($foregroundColor -and $backgroundColor) {
    Write-Host $formattedMessage -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
  } elseif ($foregroundColor) {
    Write-Host $formattedMessage -ForegroundColor $foregroundColor
  } elseif ($backgroundColor) {
    Write-Host $formattedMessage -BackgroundColor $backgroundColor
  } else {
    Write-Host $formattedMessage
  }
}
<#
Write-FormattedOutput "This is a long message"
Write-FormattedOutput "Another message" -Style Yellow -BackgroundColor Blue
Write-FormattedOutput "Default style (no color)" -Style White -BackgroundColor Red
#>