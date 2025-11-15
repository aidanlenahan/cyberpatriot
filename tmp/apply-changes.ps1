# 2.2.15 Debug programs: Remove 'Administrators'
ntrights -r SeDebugPrivilege -u Administrators

# 2.2.18 Deny log on as a service: Add 'Guests'
# Note: Will overwrite any existing assignment for this policy
$policyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$denyLogonAsServiceSID = "S-1-5-32-546" # SID for Guests
$Current = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "DenyServiceLogon")
if ($Current) {
    # If Guests not present, append
    if ($Current -notlike "*$denyLogonAsServiceSID*") {
        $NewValue = $Current + "," + $denyLogonAsServiceSID
        Set-ItemProperty -Path $policyPath -Name "DenyServiceLogon" -Value $NewValue
    }
} else {
    Set-ItemProperty -Path $policyPath -Name "DenyServiceLogon" -Value $denyLogonAsServiceSID
}

# 2.3.10.7 & 2.3.10.8: Remotely accessible registry paths/subpaths
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg" -Name "AllowedExactPaths" -Value ""
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg" -Name "AllowedPaths" -Value ""

# 2.3.10.10 Restrict remote calls to SAM: Restrict to Administrators
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictRemoteSAM" -Value "O:BAG:BAD:(A;;RC;;;BA)"

# Disable listed services
$servicesToDisable = @(
    "RpcLocator",         # 5.19
    "SSDPSRV",            # 5.26
    "upnphost",           # 5.27
    "WMPNetworkSvc",      # 5.31
    "icssvc",             # 5.32
    "XboxGipSvc",         # 5.38
    "XblAuthManager",     # 5.39
    "XblGameSave",        # 5.40
    "XboxNetApiSvc"       # 5.41
)
foreach ($service in $servicesToDisable) {
    Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Stop-Service -Name $service -ErrorAction SilentlyContinue
}

# 9.2.4 Firewall private log file name
Set-NetFirewallProfile -Profile Private -LogFileName "%SystemRoot%\System32\logfiles\firewall\privatefw.log"
# 9.3.4 Firewall public log file name
Set-NetFirewallProfile -Profile Public -LogFileName "%SystemRoot%\System32\logfiles\firewall\publicfw.log"
