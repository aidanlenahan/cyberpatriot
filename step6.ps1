# PowerShell Script for System Diagnostics and Configuration
# Save this script as `diagnostics6.ps1`

# Define the log file path
$logFile = "$PSScriptRoot\diagnostics6.txt"

# Clear the log file at the start
Clear-Content $logFile -ErrorAction SilentlyContinue

# Function to log messages with formatting
function Log-Message {
    param (
        [string]$message
    )
    Add-Content -Path $logFile -Value "----------------------------"
    Add-Content -Path $logFile -Value $message
    Add-Content -Path $logFile -Value "----------------------------`n"
}

# Option 1: Disable ALL RDP settings
function Disable-RDPSettings {
    Log-Message "Disabling ALL RDP settings"
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
    Set-Service -Name TermService -StartupType Disabled
    Stop-Service -Name TermService -Force
    Log-Message "All RDP settings have been disabled."
}

# Option 2: Look for all open ports aside from the default
function Check-OpenPorts {
    Log-Message "Checking for open ports aside from the default"
    $openPorts = netstat -an | Select-String "LISTENING" | Select-String -NotMatch "80|443|3389"
    if ($openPorts) {
        $openPorts | ForEach-Object { Log-Message "Open port found: $_" }
    } else {
        Log-Message "No unusual open ports found."
    }
}

# Option 3: Enable automatic Windows updates through Group Policy
function Enable-AutoWindowsUpdates {
    Log-Message "Enabling automatic Windows updates through Group Policy"
    Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name "NoAutoUpdate" -Value 0
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name "AUOptions" -Value 4 -PropertyType DWORD -Force
    Log-Message "Automatic Windows updates have been enabled through Group Policy."
}

# Option 4: Configure INF Template and Analyze
function Configure-INFTemplate {
    Log-Message "Configuring INF Template for Security Settings"
    $templatePath = "$PSScriptRoot\Win10_Template.inf"
    $databasePath = "$PSScriptRoot\rbr_template.sdb"
    if (-Not (Test-Path $templatePath)) {
        Log-Message "Error: Template file Win10_Template.inf not found at $templatePath."
        return
    }
    secedit /import /db $databasePath /cfg $templatePath /overwrite
    Log-Message "Template Win10_Template.inf imported to database rbr_template.sdb"
    secedit /analyze /db $databasePath
    Log-Message "System analyzed for security settings based on the template."
    secedit /configure /db $databasePath
    Log-Message "System configured with security settings from Win10_Template.inf."
    secedit /analyze /db $databasePath
    Log-Message "Post-configuration analysis completed. Any remaining misconfigurations will be shown."
    Remove-Item -Path $databasePath -Force
    Log-Message "Configuration and analysis process completed. Database file removed."
}

# Option 5: Turn off World Wide Web Publishing Service (W3SVC)
function Disable-WWWPublishingService {
    Log-Message "Turning off World Wide Web Publishing Service (W3SVC)"
    Stop-Service -Name W3SVC -Force -ErrorAction SilentlyContinue
    Set-Service -Name W3SVC -StartupType Disabled
    Log-Message "World Wide Web Publishing Service (W3SVC) has been turned off and disabled."
}

# Option 6: Turn off SSH (Secure Shell)
function Disable-SSHService {
    Log-Message "Turning off SSH (Secure Shell) Service"
    $sshServiceName = "sshd"
    if (Get-Service -Name $sshServiceName -ErrorAction SilentlyContinue) {
        Stop-Service -Name $sshServiceName -Force
        Set-Service -Name $sshServiceName -StartupType Disabled
        Log-Message "SSH service has been turned off and disabled."
    } else {
        Log-Message "SSH service (sshd) is not installed or not running."
    }
}

# Main script logic
Write-Host "Select an option:"
Write-Host "1: Disable ALL RDP settings"
Write-Host "2: Look for all open ports aside from the default"
Write-Host "3: Enable automatic Windows updates through Group Policy"
Write-Host "4: Configure INF Template and Analyze"
Write-Host "5: Turn off World Wide Web Publishing Service (W3SVC)"
Write-Host "6: Turn off SSH (Secure Shell) Service"
Write-Host "A: Perform ALL actions"
Write-Host "Q: Quit"
$choice = Read-Host "Enter your choice (1, 2, 3, 4, 5, 6, A, Q)"

switch ($choice) {
    "1" { Disable-RDPSettings }
    "2" { Check-OpenPorts }
    "3" { Enable-AutoWindowsUpdates }
    "4" { Configure-INFTemplate }
    "5" { Disable-WWWPublishingService }
    "6" { Disable-SSHService }
    "A" {
        Disable-RDPSettings
        Check-OpenPorts
        Enable-AutoWindowsUpdates
        Configure-INFTemplate
        Disable-WWWPublishingService
        Disable-SSHService
    }
    "Q" { Write-Host "Exiting script."; return }
    default { Write-Host "Invalid option selected" }
}

Write-Host "Actions completed. Check the diagnostics6.txt file for details."
