<#
.SYNOPSIS
    Completes Step 1 of the Windows CyberPatriot checklist.
    This script configures File Explorer to show hidden files and file extensions.

.DESCRIPTION
    This script modifies the necessary registry settings to make hidden files visible and to show file extensions for all file types in File Explorer.
    It includes a diagnostics feature to verify that the changes have been applied successfully.
    A transcript of the script's execution is saved to a log file.

.NOTES
    Author: Gemini
    Date: 2025-11-15
#>
[CmdletBinding()]
param()

# Start logging
$LogPath = "C:\CyberPatriot\Logs"
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}
Start-Transcript -Path "$LogPath\step1-log.txt" -Append

function Test-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$ExpectedValue
    )
    try {
        $ActualValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
        if ($ActualValue -eq $ExpectedValue) {
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

try {
    Write-Verbose "Starting Step 1: Configuring File Explorer settings."

    # Unhide hidden files in File Explorer
    Write-Verbose "Setting registry key to show hidden files."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Force

    # Show file extensions
    Write-Verbose "Setting registry key to show file extensions."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force

    # Verification
    Write-Verbose "Verifying registry changes."
    $hiddenFilesVisible = Test-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -ExpectedValue 1
    $fileExtVisible = Test-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -ExpectedValue 0

    if ($hiddenFilesVisible -and $fileExtVisible) {
        Write-Host "Successfully configured File Explorer settings." -ForegroundColor Green
    } else {
        Write-Host "Failed to configure one or more File Explorer settings." -ForegroundColor Red
    }

    # Refresh Explorer to apply changes
    # This uses P/Invoke to call the SendMessageTimeout function from user32.dll to broadcast a settings change message to all windows.
    Write-Verbose "Refreshing Explorer to apply changes."
    $signature = @"
[DllImport("user32.dll")]
public static extern void SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, IntPtr lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@
    Add-Type -MemberDefinition $signature -Namespace WinAPI -Name User32
    [WinAPI.User32]::SendMessageTimeout([IntPtr]::Zero, 0x1A, [UIntPtr]::Zero, [IntPtr]::Zero, 0, 1000, [ref]([UIntPtr]::Zero))

    Write-Host "Hidden files are now visible and file extensions are shown." -ForegroundColor Green
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Verbose "Step 1 script finished."
    Stop-Transcript
}
