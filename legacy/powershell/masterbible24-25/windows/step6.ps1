# This script completes step 6 of Windows in Cyberpatriot
# https://docs.google.com/document/d/e/2PACX-1vT2zjA8CaPWgSmMfjuAQXL91jd2ioXfFl3J_zvzhtXNg7lFbNFENRbakHlqrodOCvrJ8hJ_O5YRnCyt/pub

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

    # Disabling RDP settings
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
    Set-Service -Name TermService -StartupType Disabled
    Stop-Service -Name TermService -Force

    Log-Message "All RDP settings have been disabled."
}

# Option 2: Look for all open ports aside from the default
function Check-OpenPorts {
    Log-Message "Checking for open ports aside from the default"

    # Finding open ports other than common defaults (e.g., 80, 443, 3389)
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

    # Setting Windows Update policy
    Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name "NoAutoUpdate" -Value 0
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name "AUOptions" -Value 4 -PropertyType DWORD -Force

    Log-Message "Automatic Windows updates have been enabled through Group Policy."
}

# Option 4: Configure INF Template and Analyze
function Configure-INFTemplate {
    Log-Message "Configuring INF Template for Security Settings"

    # Define the template path (assuming the template is in the same directory as the script)
    $templatePath = "$PSScriptRoot\Win10_Template.inf"
    $databasePath = "$PSScriptRoot\rbr_template.sdb"

    # Check if the template file exists
    if (-Not (Test-Path $templatePath)) {
        Log-Message "Error: Template file Win10_Template.inf not found at $templatePath."
        return
    }

    # Create the security database and import the template
    secedit /import /db $databasePath /cfg $templatePath /overwrite
    Log-Message "Template Win10_Template.inf imported to database rbr_template.sdb"

    # Perform the security analysis
    secedit /analyze /db $databasePath
    Log-Message "System analyzed for security settings based on the template."

    # Configure the system to apply the security settings from the template
    secedit /configure /db $databasePath
    Log-Message "System configured with security settings from Win10_Template.inf."

    # Re-analyze to confirm the changes
    secedit /analyze /db $databasePath
    Log-Message "Post-configuration analysis completed. Any remaining misconfigurations will be shown."

    # Cleanup: Optional cleanup if you wish to delete the database file after use
    Remove-Item -Path $databasePath -Force
    Log-Message "Configuration and analysis process completed. Database file removed."
}

# Main script logic
Write-Host "Select an option:"
Write-Host "1: Disable ALL RDP settings"
Write-Host "2: Look for all open ports aside from the default"
Write-Host "3: Enable automatic Windows updates through Group Policy"
Write-Host "4: Configure INF Template and Analyze"
Write-Host "A: Perform ALL actions"
$choice = Read-Host "Enter your choice (1, 2, 3, 4, A)"

switch ($choice) {
    "1" { Disable-RDPSettings }
    "2" { Check-OpenPorts }
    "3" { Enable-AutoWindowsUpdates }
    "4" { Configure-INFTemplate }
    "A" {
        Disable-RDPSettings
        Check-OpenPorts
        Enable-AutoWindowsUpdates
        Configure-INFTemplate
    }
    default { Write-Host "Invalid option selected" }
}

Write-Host "Actions completed. Check the diagnostics6.txt file for details."
