# Enable Windows Firewall for all profiles (Domain, Private, and Public)
Write-Host "Enabling Windows Firewall for all profiles..."
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True

# Set default action for inbound connections to block
Write-Host "Setting default inbound action to Block for all profiles..."
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultInboundAction Block

# Set default action for outbound connections to allow
Write-Host "Setting default outbound action to Allow for all profiles..."
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultOutboundAction Allow

# Enable logging of dropped packets and successful connections for all profiles
Write-Host "Enabling logging of dropped packets and successful connections..."
Set-NetFirewallProfile -Profile Domain,Private,Public -LogAllowed True
Set-NetFirewallProfile -Profile Domain,Private,Public -LogBlocked True
Set-NetFirewallProfile -Profile Domain,Private,Public -LogFileName '%SystemRoot%\System32\LogFiles\Firewall\pfirewall.log'
Set-NetFirewallProfile -Profile Domain,Private,Public -LogMaxSizeKilobytes 4096

# Enable basic inbound firewall rules (Remote Desktop and File Sharing)
Write-Host "Enabling essential inbound firewall rules..."

# Enable Remote Desktop rule (if needed)
Enable-NetFirewallRule -DisplayName "Remote Desktop - User Mode (TCP-In)"

# Enable File and Printer Sharing rule (for local network)
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

Write-Host "Windows Firewall is now configured with basic recommended settings."
