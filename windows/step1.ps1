# This script completes step 1 of Windows in Cyberpatriot
# https://docs.google.com/document/d/e/2PACX-1vT2zjA8CaPWgSmMfjuAQXL91jd2ioXfFl3J_zvzhtXNg7lFbNFENRbakHlqrodOCvrJ8hJ_O5YRnCyt/pub

# Unhide hidden files in File Explorer
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

# Show file extensions
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Refresh Explorer to apply changes
$signature = @"
[DllImport("user32.dll")]
public static extern void SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, IntPtr lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@
Add-Type -MemberDefinition $signature -Namespace WinAPI -Name User32
[WinAPI.User32]::SendMessageTimeout([IntPtr]::Zero, 0x1A, [UIntPtr]::Zero, [IntPtr]::Zero, 0, 1000, [ref]([UIntPtr]::Zero))

Write-Host "Hidden files are now visible and file extensions are editable."
