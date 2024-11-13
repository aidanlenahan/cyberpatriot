# This script completes step 5 of Windows in Cyberpatriot
# https://docs.google.com/document/d/e/2PACX-1vT2zjA8CaPWgSmMfjuAQXL91jd2ioXfFl3J_zvzhtXNg7lFbNFENRbakHlqrodOCvrJ8hJ_O5YRnCyt/pub

# Define the path for the diagnostics report
$diagnosticsFile = "$PSScriptRoot\diagnostics5.txt"

# Append a new section header to the diagnostics file with the date and time
"" | Out-File -FilePath $diagnosticsFile -Append
"--- Security Service Check Report ---" | Out-File -FilePath $diagnosticsFile -Append
"Generated on $(Get-Date -Format "MM/dd/yyyy HH:mm:ss")" | Out-File -FilePath $diagnosticsFile -Append
"" | Out-File -FilePath $diagnosticsFile -Append

# Define services to check with descriptions
$servicesToCheck = @{
    "RemoteRegistry" = "Allows remote users to modify registry settings";
    "TermService" = "Enables Remote Desktop";
    "TapiSrv" = "Telephony Service";
    "FTPSVC" = "FTP Server Service";
    "SNMPTRAP" = "SNMP Trap Service";
    "SMTPSVC" = "SMTP Service";
    "irmon" = "Infrared Monitor Service";
    "PlugPlay" = "Plug and Play Service"
}

# Check each service and disable if necessary
foreach ($serviceName in $servicesToCheck.Keys) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service) {
        # Document service status
        $statusMessage = "$serviceName ($($servicesToCheck[$serviceName])) - Status: $($service.Status)"
        $statusMessage | Out-File -FilePath $diagnosticsFile -Append

        # Disable service if it's running or set to start automatically
        if ($service.Status -ne 'Stopped' -or $service.StartType -eq 'Automatic') {
            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
            $changeMessage = "Action: $serviceName disabled and stopped for security."
        } else {
            $changeMessage = "No action needed. $serviceName is already secure."
        }
        # Append change to diagnostics file
        $changeMessage | Out-File -FilePath $diagnosticsFile -Append
        "" | Out-File -FilePath $diagnosticsFile -Append # Blank line for readability
    } else {
        # Log if the service is not found
        "Service $serviceName not found." | Out-File -FilePath $diagnosticsFile -Append
        "" | Out-File -FilePath $diagnosticsFile -Append # Blank line for readability
    }
}

# Notify completion
"--- End of Report ---" | Out-File -FilePath $diagnosticsFile -Append
Write-Output "Diagnostics report appended to $diagnosticsFile"
