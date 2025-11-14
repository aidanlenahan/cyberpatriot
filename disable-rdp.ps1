# Disable Remote Desktop (equivalent to GP: Allow users to connect remotely -> Disabled)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
    -Name "fDenyTSConnections" -Type DWord -Value 1

# Ensure the RDP service is not listening
Set-Service -Name TermService -StartupType Disabled -ErrorAction SilentlyContinue

# Optional: Stop the service if currently running
Stop-Service -Name TermService -Force -ErrorAction SilentlyContinue
