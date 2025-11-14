# CyberPatriot Windows 10 Toolkit [OLD]

Useful links:
- [CyberPatriot Training Modules](https://www.uscyberpatriot.org/competition/training-materials/training-modules)
- [Wired: Windows 10 Security Settings](https://www.wired.com/2015/08/windows-10-security-settings-need-know/)
- [Microsoft: Configure Security Policy Settings](https://docs.microsoft.com/en-us/windows/device-security/security-policy-settings/how-to-configure-security-policy-settings)
- [MSDN Security Library](https://msdn.microsoft.com/en-us/library/ff648641.aspx)
- [CyberPatriot Windows Checklist (PDF)](http://www.lacapnm.org/Cadets/STEM/CyberPatriot/SeasonVIII/CyberPatriot_Windows_CheckList.pdf)

***

## Quick Actions

- Forensic Question
- Updates:  
  `Start > search "Windows update" > check for updates`
- Update Policy:  
  `Start > search "Windows Update" > Advanced settings`
- Notification Settings:  
  `Start > search "User Account Control Setting" > Slide bar to "Always Notify"`
- User Files:  
  `File Folder Icon > This PC > C Drive (OS(C:)) > Users > Select Suspicious User`
- Delete User:  
  `File Folder Icon > This PC > C Drive (OS(C:)) > Users > right-click bad user > Delete`
- User Accounts:  
  `Start > search "Control Panel" > User Accounts`
  - Change account type:  
    `Control Panel > User Accounts > Change account type`
  - Manage another account:  
    `Control Panel > User Accounts > Manage another account > select user > change the account type`
- Users and Groups:  
  `Start > search "Command Prompt" > type "LUSRMGR"`
- Change Passwords:  
  - For your account:
    `Control Panel > User Accounts > Make changes to my account in PC settings > sign-in options`
  - For others:
    `Control Panel > User Accounts > Manage another account > select user > Create a password`
  - Quick:  
    `Ctrl+Alt+Delete > Change a password`
- Password Policy:  
  `Command Prompt > type "SECPOL.MSC" > Password Policy`
- Account Lockout Policy:  
  `Command Prompt > type "SECPOL.MSC" > Account Lockout Policy`
- Firewall Settings:  
  `Control Panel > Windows Firewall`
- Turn On Firewall/Install Maintenance:  
  `Control Panel > Windows Firewall > Security and Maintenance (bottom left)`
- Antivirus:  
  `Start > search "Windows Defender"`
  -  
    `Settings > Update & Security > Windows Defender > Open Windows Defender Security Center`
- Disable Ports:  
  `Use firewall to disable (FTP: port 53)`

***

## CyberPatriot Competition Checklist

| Action Item                      | Manual | Automated |
|-----------------------------------|--------|-----------|
| Read the Read Me file             | ⃝      |           |
| User Rights – update registry     | ⃝      |           |
| Answer Forensics Question(s)      | ⃝      |           |
| MalwareBytes for malware          | ⃝      |           |
| Turn on Firewall                  | ⃝      |           |
| Automatic Updates – download/install | ⃝   |           |
| Action Center                     | ⃝      |           |
| AV scan                           | ⃝      |           |
| User Account Control              | ⃝      |           |
| Secure Users and Groups           | ⃝      |           |
| Passwords for accounts            | ⃝      |           |
| Password Policies                 | ⃝      |           |
| Remove/Disable Insecure Services  | ⃝      |           |
| Local Security Policy (.inf file) | ⃝      |           |
| Update appropriate software       | ⃝      |           |
| Uninstall unnecessary software    | ⃝      |           |
| Search for inappropriate files    | ⃝      |           |
| Secure File and Directory Shares  | ⃝      |           |
| Check Open Ports                  | ⃝      |           |
| Check for Anti-Virus Program      | ⃝      |           |
| Check for abnormal behavior       | ⃝      |           |

- **Important:**  
  Ensure you are not rebooting the machine for updates with less than an hour to go!
- Document each and every action you perform – whether the setting works or not.
- Write notes here. Use the back of this paper or ask for a new sheet if more room is needed.

***

## Securing Windows 7/10

### Password Policies
- Password History: 5 Days
- Maximum Password Age: 30-90 days
- Minimum Password Age: 5 days
- Minimum Password Length: 8 characters
- Password Complexity: Enabled
- Reverse Encryptions: Disabled

### Account Lockout Policies
- Account Lockout Duration: 30 minutes
- Account Lockout Threshold: 3 attempts
- Reset account lockout counter: 30 minutes

### Audit Policies

Set up from `Local Policies > Audit Policies`:
- Audit Logon Events: Failure
- Audit Account Management: Success
- Audit Directory Service: ND
- Audit Objects Access: ND
- Audit Policy Change: Success
- Audit Privilege use: Success/Failure
- Audit Process Tracking: Success/Failure
- Audit System Events: Failure

### Security Options

Found under `Local Policies > User Rights Assignment`:
- Disable Administrator account
- Disable Guest account
- Rename administrator and guest accounts
- Shutdown without log on

***

## Windows Firewall

- **Turn on Windows Firewall!**
- **Change passwords for each user (User policy).**
- **Install automatic updates:**  
  From Control Panel > Action Tools under System in security.
- **Update Windows Programs:**  
  (PowerShell, IE up to 10)
- **Set local user Admin password to not expire and account enabled:**  
  `Admin tools > Computer management > users and group`
- **Disable and Stop Services:**  
  - RDP
  - ICS
  - RDP User Mode
  - Remote Registry
  - RD Configuration
  - SSDP Discovery
  - UPnP Device Host
  - Remote Desktop
  - WWW Publishing Service

### Host File

- Clean the Host file:  
  `C:\Windows\System32\drivers\etc\host.txt`

### Deny the Following Ports

- FTP
- SSH
- TelNet
- SNMP
- LDAP
- RDP

***

### Service Packs

- Windows 7 Service packs Installed
