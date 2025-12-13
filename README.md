# Windows Server CyberPatriot Image Hardening

This guide provides a step-by-step approach to hardening a Windows Server CyberPatriot image for security. Each step includes specific tasks and scripts aimed at improving the security posture of the system. Below is an overview of the steps, resources, and tasks involved.

---

## Step 0 - Initial Setup
### Tasks:
- **Create Required Groups:** Set up the necessary user groups.
- **Create Required Users:** Create the required user accounts.
- **Install Necessary Programs:** Ensure all required software is installed on the system.

---

## [Step 1 - Initialization](step1.ps1)
### Tasks:
1. **Set Script Execution Policy:**
   - Make `.ps1` scripts executable with the command:
     ```powershell
     Set-ExecutionPolicy Unrestricted -Scope LocalMachine
     ```
2. **View Hidden Files:**
   - Enable the visibility of all hidden files.
3. **Enable File Extension Editing:**
   - Allow file extensions to be editable.
4. **Answer Forensics Questions:**
   - Complete any provided forensics questions.

### Output:
- `diagnostics/diagnostics1.txt`

---

## Step 2 - Forensics Tools
### Recommended Resources:
- **CyberChef**
- **ChatGPT**
- **Cryptii**
- **GitHub Copilot**

---

## [Step 3 - Basic Security](step3.ps1)
### Tasks:
1. **Enable Firewall:**
   - Ensure the Windows Firewall is turned on for Domain, Public, and Private profiles.
2. **Enable Real-Time Protection:**
   - Verify that Windows Defender real-time protection is enabled.
3. **List File Shares:**
   - List all SMB shares on the system for review.
4. **Remove Unwanted Software:**
   - Detect and identify unauthorized software including:
     - Wireshark, CCleaner, Npcap, PC Cleaner, Network Stumbler, L0phtCrack, JDownloader, and games.
5. **Remove Unwanted Files:**
   - Identify media and document files that may be unauthorized:
     - Audio/Video: mp3, mp4, mov, wav, aac, flac, mkv
     - Images: png, jpeg, jpg, gif, tiff, bmp
     - Documents: pdf, doc, docx
     - Executables: exe, msi, cmd

### Output:
- `diagnostics/diagnostics3.txt`

---

## [Step 4 - Users and Groups](step4.ps1)
### Tasks:
1. **Disable Unauthorized Users:**
   - Disable any local users not in the authorized users list.
2. **Manage Administrators Group:**
   - Ensure only authorized administrators are in the Administrators group.
3. **Disable Guest and Administrator Accounts:**
   - Disable both the default Guest and Administrator accounts.
4. **Set User Passwords:**
   - Apply a standardized password for all local users.
5. **Disable Password Never Expires:**
   - Ensure no accounts have "Password Never Expires" enabled.

#### How to Execute This Script:
1. **Run the script `step4.ps1` first.** It will create a template file named `authusers.txt`.
2. **Edit `authusers.txt`** with the list of authorized users from the README.
3. **Run `step4.ps1` again** to apply changes.
4. **Check `diagnostics/diagnostics4.txt`** for updates.

### Output:
- `diagnostics/diagnostics4.txt`

---

## [Step 5 - Services](step5.ps1)
### Tasks:
- **Disable Unnecessary Services:** Check and disable the following potentially insecure services:
  - Remote Registry (allows remote registry modification)
  - Remote Desktop Services / TermService (enables RDP)
  - Telephony (TapiSrv - legacy devices)
  - FTP Server Service (FTPSVC)
  - SNMP Trap Service (SNMPTRAP)
  - SMTP Service (SMTPSVC)
  - Infrared Monitor Service (irmon)
  - Plug and Play Service (PlugPlay)

### Output:
- `diagnostics/diagnostics5.txt`

---

## [Step 6 - Miscellaneous (Interactive)](step6.ps1)
### Options:
1. **Disable ALL RDP Settings:**
   - Disable Terminal Services and deny RDP connections.
2. **Check for Open Ports:**
   - Identify non-standard open ports (excluding 80, 443, 3389).
3. **Enable Automatic Windows Updates:**
   - Configure automatic updates through Group Policy.
4. **Configure INF Template:**
   - Apply security settings from Win10_Template.inf.
5. **Disable Web Server Services:**
   - Turn off World Wide Web Publishing Service (W3SVC).
6. **Disable SSH Service:**
   - Turn off SSH (sshd) service.
7. **A. Perform ALL Actions:**
   - Execute all security measures at once.

**Note:** This script is interactive. You can select individual options or choose 'A' to perform all actions. Use `-RunAll` parameter for non-interactive mode.

### Output:
- `diagnostics/diagnostics6.txt`

---

## [Step 7 - Points Hunting](step7.ps1)
### Tasks:
**Comprehensive Security Audit:**
1. **Check for Suspicious Processes:**
   - Detect potentially malicious processes including:
     - nc, netcat, ncat (network tools)
     - vncviewer, teamviewer, anydesk (remote access)
     - xmr-stak, kismet, wireshark, putty
2. **Identify Open Ports:**
   - List all listening TCP ports for review.
3. **Check for FTP Services:**
   - Detect any running FTP-related services.
4. **Review Scheduled Tasks:**
   - List all enabled scheduled tasks.
5. **Examine Recent Event Logs:**
   - Review recent Security event logs.
6. **Disable SMBv1 Protocol:**
   - Disable SMBv1 to prevent remote exploitation vulnerabilities.

### Output:
- `diagnostics/diagnostics7.txt`

---

## Important Notes
- Run all scripts with Administrator privileges.
- Scripts should be run in order: 1, 3, 4, 5, 6, 7 (Step 2 is manual forensics).
- Step 4 requires manual configuration of `authusers.txt` before the second run.
- Step 6 is interactive and presents a menu of options.
- All scripts generate diagnostics files in the `diagnostics/` subdirectory.
- **Diagnostics files are appended to** (not overwritten) - maintaining a complete audit trail.
- Logs are also saved to `C:\CyberPatriot\Logs\` for transcript logging.

---

## Windows Server Baselines
This branch includes Windows Server security baselines in the `critical-files/` directory:
- Windows Server 2022 Security Baseline
- LGPO configurations for server hardening
- CIS benchmark reports

---

## Common Problems
After applying the INF part of step 6, it may be difficult to install `.exe` or `.msi`. If this is the case, use `msiexec /i "C:\path\to\package.msi"` in an admin Command Prompt.

---

## License
This guide is designed for use in CyberPatriot competitions and may be adapted for other cybersecurity competitions or educational purposes.
