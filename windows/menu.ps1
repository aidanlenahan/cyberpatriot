# menu.ps1
# Windows MasterBible Menu Script with logging and help submenu

$logFile = "menu-diagnostics.txt"

# Log function to append events with timestamps
function Log-Event {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logMessage
}

function Show-Menu {
    Clear-Host
    Write-Output "Windows MasterBible"
    Write-Output "================="
    Write-Output ""
    Write-Output "Choose one of the following:"
    Write-Output "1 Initialize (step1.ps1)"
    Write-Output "2 Print helpful tools for forensics questions"
    Write-Output "3 Apply Basic Security (step3.ps1)"
    Write-Output "4 Users and Groups (step4.ps1)"
    Write-Output "5 Disable Unwanted Services (step5.ps1)"
    Write-Output "6 Look through miscellaneous options (step6.ps1)"
    Write-Output "7 Backdoors (step7.ps1)"
    Write-Output "A About"
    Write-Output "H Help"
    Write-Output "Q Quit"
    Write-Output ""
}

function Run-Script {
    param (
        [string]$scriptPath
    )
    if (Test-Path $scriptPath) {
        Write-Output "Running $scriptPath..."
        Log-Event "Running $scriptPath"
        & $scriptPath
    } else {
        Write-Output "Error: Script $scriptPath not found."
        Log-Event "Error: Script $scriptPath not found"
    }
    Write-Output "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}


# submenu help menu
function Show-HelpMenu {
    do {
        Clear-Host
        Write-Output "Help Menu"
        Write-Output "========="
        Write-Output ""
        Write-Output "1 Initialize (step1.ps1)"
        Write-Output "2 Forensics Tools"
        Write-Output "3 Apply Basic Security (step3.ps1)"
        Write-Output "4 Users and Groups (step4.ps1)"
        Write-Output "5 Disable Unwanted Services (step5.ps1)"
        Write-Output "6 Miscellaneous Options (step6.ps1)"
        Write-Output "7 Backdoors (step7.ps1)"
	Write-Output ""
	Write-Output "All steps (excluding step 1 & 2) have a corresponding diagnostics[num].txt file, where all changes are automatically documented."
	Write-Output "menu-diagnostics.txt will briefly document all tasks executed within menu.ps1."
	Write-Output ""
        Write-Output "A About"
        Write-Output "Q Back to Main Menu"
        Write-Output ""
        
        $helpChoice = Read-Host "Enter the number or letter of the option to see its description, or 'Q' to return to the main menu"

        switch ($helpChoice.ToUpper()) {
            '1' { Write-Output "`nInitialize: Runs step1.ps1 to initialize basic settings such as viewing hidden files and making file extensions editable."; Log-Event "Viewed help for Initialize" }
            '2' { Write-Output "`nForensics Tools: Displays useful tools for forensics questions (this step does not have a script to execute)"; Log-Event "Viewed help for Forensics Tools" }
            '3' { Write-Output "`nApply Basic Security: Runs step3.ps1 to apply basic security settings such as enabling firewall, enabling real-time protection, printing bad shares to diagnostics, prints unwanted software to diagnostics."; Log-Event "Viewed help for Basic Security" }
            '4' { Write-Output "`nUsers and Groups: Runs step4.ps1 which does the following:`n1. Creates authusers.txt, which is a template file to paste authorized users into`n2. A ChatGPT prompt can be used along with the authorized users section of the README. ChatGPT will format the list accordingly.`n3. Paste the output of ChatGPT into authusers.txt`4. Run Users and Groups (step4.ps1) once more. This will disable all users that do not appear on this list, along with disabling the Guest and Administrator accounts.`nThis step will also make sure only authorized users are on the Administrators group and set password never expires to OFF"; Log-Event "Viewed help for Users and Groups" }
            '5' { Write-Output "`nDisable Unwanted Services: Runs step5.ps1 to disable unnecessary or insecure services.`nThis will disable Remote Registry, Remote Desktop Services, Telephony, FTP (Windows FTP), SNMP Trap, SMTP, Infrared monitor service, Plug and Play"; Log-Event "Viewed help for Unwanted Services" }
            '6' { Write-Output "`nMiscellaneous Options: Opens submenu tools (step6.ps1) which can be executed individually or separately.`nThese options consist of Disabling RDP, checking for open ports, enabling auto Windows updates, configuring an INF template, disabling WWWPublishingService, and disabling the SSH service"; Log-Event "Viewed help for Miscellaneous Options" }
            '7' { Write-Output "`nBackdoors: Searches for backdoors (step7.ps1) by checking for suspicious processes, backdoors, open ports, FTP services, listing tasks in Task Scheduler."; Log-Event "Viewed help for Backdoors" }
            'A' { Write-Output "`nAbout: Provides additional information about script."; Log-Event "Viewed help for About" }
            'Q' { Write-Output "Returning to Main Menu..."; Log-Event "Exited Help Menu" }
            default { Write-Output "Invalid choice. Please enter a valid option." }
        }
        
        Write-Output "`nPress any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    } until ($helpChoice.ToUpper() -eq 'Q')
}

# Main Loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice"

    switch ($choice.ToUpper()) {
        '1' { Log-Event "Selected Initialize"; Run-Script ".\step1.ps1" }
        '2' { 
            Write-Output "Printing helpful tools for forensics questions..."
            Log-Event "Selected Forensics Tools"
            Write-Output "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '3' { Log-Event "Selected Apply Basic Security"; Run-Script ".\step3.ps1" }
        '4' { Log-Event "Selected Users and Groups"; Run-Script ".\step4.ps1" }
        '5' { Log-Event "Selected Disable Unwanted Services"; Run-Script ".\step5.ps1" }
        '6' { 
            Write-Output "Opening Miscellaneous Options (step6.ps1)..."
            Log-Event "Selected Miscellaneous Options"
            Run-Script ".\step6.ps1"
        }
        '7' { Log-Event "Selected Backdoors"; Run-Script ".\step7.ps1" }
        'A' { 
            Write-Output "Windows MasterBible: A script collection to help with Windows security and forensics tasks."
	    Write-Output "Created by Aidan Lenahan for Cyberpatriot, github.com/aidanlenahan"
	    Write-Output "Email me with any questions: d9hhhh@gmail.com"
	    Write-Output "aidanlenahan.com"
            Log-Event "Selected About"
            Write-Output "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        'H' { Log-Event "Opened Help Menu"; Show-HelpMenu }
        'Q' { Write-Output "Exiting Windows MasterBible."; Log-Event "Exited menu" }
        default {
            if ($choice -match '^help\s+(\w)$') {
                Show-Help $matches[1]
                Log-Event "Requested help for option $matches[1]"
                Write-Output "`nPress any key to continue..."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            } else {
                Write-Output "Invalid choice. Please enter a valid option."
                Log-Event "Invalid choice entered: $choice"
                Write-Output "`nPress any key to continue..."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        }
    }

} until ($choice -match '^(Q|quit)$')
