# The Ultimate Windows Checklist (2018, R3)

**Authors:**

* Parsia Bahrami (2018 revision)
* Ethan Hoadley and Nick Fortin (2016 revision)

**Based on:**
*The Glorious Reworked Windows 7 Checklist 2014*
by Charlie Franks, Michael Bailey, Paul Benoit, Quiana Dang

**Note:**
This checklist is not perfectly comprehensive. Every Windows installation differs. If something appears that is not listed here, use good judgment. Search engines are extremely helpful.

---

# Table of Contents

1. View Hidden Files
2. Net Shares
3. Malwarebytes
4. CCleaner
5. Spybot – Search and Destroy
6. Unwanted Programs
7. User and Group Configuration
8. Firewall
9. Clear DNS Cache
10. Policies
11. System Restore
12. Services
13. Remote Desktop
14. Automatic Updating
15. User Account Control Configuration
16. Processes and Open Ports
17. Programs in Startup
18. Adding / Removing Windows Components
19. Disabling Dump File Creation
20. Saved Windows Credentials
21. Internet Options (Internet Explorer)
22. Power Settings
23. Data Execution Prevention
24. Malicious Drivers
25. GMER Scan
26. Microsoft Baseline Security Analyzer Scan
27. Service Packs
28. Updating via Control Panel
29. Administrative Templates (Advanced Hardening)

---

# 1. Viewing Hidden Files

1. Open **Windows Explorer / My Computer**.
2. Select **Organize** (upper-left).
3. Choose **Folder and Search Options**.
4. Go to the **View** tab.
5. Enable **Show hidden files and folders**.
6. Disable **Hide extensions for known file types**.
7. Disable **Hide protected operating system files**.
8. Disable **Hide empty drives**.

**Server 2008 Note:**
Control Panel → Folder Options → View → Show Hidden Files, etc.

---

# 2. Net Shares

1. Open the Start menu and type: `cmd`
2. **Right-click** → **Run as Administrator**
3. Approve any UAC prompt.
4. Type:

   ```
   net share
   ```

   This lists all active shares.
5. To delete a share:

   ```
   net share /delete <SHARENAME>
   ```
6. Hidden shares contain a `$` — they must still be removed.
7. Remove **every** share except the defaults.
8. Default auto-regenerated shares:

   * `IPC$`
   * `C$`
   * `ADMIN$`

---

# 3. Malwarebytes

1. Download Malwarebytes (latest version).
2. Update when prompted.
3. During install, uncheck **Enable Malwarebytes PRO**.
4. Select **Full Scan**, then **Scan**.
5. Let the scan run in the background; newer versions take a long time.
6. When complete, click **Show Results**, select all, and **Remove Selected**.

---

# 4. CCleaner

1. Download and install CCleaner with default recommended settings.
2. When asked about cookie scanning, choose **No**.
3. Select **Analyze**.
4. Select all findings → **Run Cleaner**.
5. Go to **Registry** tab → **Scan for Issues**.
6. Select all → **Fix Selected Issues**.
7. Save the `.reg` backup when prompted.

---

# 5. Spybot – Search and Destroy

1. Download the latest version of Spybot.
2. During install, choose:
   *I want more control, more feedback, and more responsibility.*
3. After install:

   * Check **Open Start Center**
   * Check **Check for new malware signatures**
4. Update repeatedly until fully up to date.
5. In Start Center, run a **System Scan**.
6. Remove all malicious/unwanted findings.

---

# 6. Removing Unwanted Software

1. Open Control Panel → **Uninstall a Program**.
2. Uninstall **everything except**:

   * Malwarebytes
   * Microsoft Visual C++
   * Microsoft .NET
   * (Remove CCleaner *if* it was preinstalled before this process.)
3. If “Access Denied / In Use” occurs → end the process in Task Manager.
4. Some software hides via registry. Open:

   ```
   regedit
   ```

   **Warning:** modifying registry can break the Windows install.
5. Navigate to:

   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
   ```
6. Look for entries not shown in the normal Add/Remove Programs list.

---

# 7. Updating Programs

There is no single method. You may:

* Open the program → check for updates.
* Download the latest stable installer.
* Uninstall and reinstall cleanly with the newest version.

---

# 8. User and Group Configuration

1. Start → type: `MMC` → Enter
2. File → Add/Remove Snap-ins → Add **Local Users and Groups**.
3. Default built-in accounts:

   * Administrator
   * Guest

## Disable Unwanted Users

Do **not** delete accounts — only disable them.

## Renaming Accounts

1. Identify if you are currently logged in as the built-in *Administrator*.
2. If you are using the default Administrator, **do not rename it**.
3. If not, rename the *Administrator* account.
4. Disable the **Guest** account.

## Set Passwords

Set a password for all non-disabled accounts.

## Administrators Group

Open the **Administrators** group and verify membership.

---

# 9. Firewall

1. Start → type: `MMC`
2. File → Add/Remove Snap-ins → **Windows Firewall with Advanced Security**
3. Open **Windows Firewall Properties**.
4. For **Domain / Private / Public** profiles:

   * Firewall: **On**
   * Inbound: **Block**
   * Outbound: **Allow**
   * Logging → Customize →

     * Log dropped packets: **Yes**
     * Log successful connections: **Yes**
     * Log size: **6500**

## Inbound Rules

Disable rules related to:

* Telnet
* nc / ncat / netcat
* File & Printer Sharing
* Remote Assistance
* Remote Desktop
* SNMP / SMTP
* Any additional remote-access entries

---

# 10. Clear DNS Cache

```
ipconfig /flushdns
```

---

# 11. Policies

Open MMC → Add **Group Policy Object Editor**.

If GPOE is unavailable (e.g., Windows Home), skip this entire section.

Below are the policy configurations exactly as required.

---

## 11.1 Password Policy

| Policy                                      | Setting  |
| ------------------------------------------- | -------- |
| Enforce Password History                    | 8        |
| Maximum Password Age                        | 14       |
| Minimum Password Age                        | 8        |
| Minimum Password Length                     | 8        |
| Password must meet complexity requirements  | Enabled  |
| Store passwords using reversible encryption | Disabled |

---

## 11.2 Account Lockout Policy

| Policy                              | Setting |
| ----------------------------------- | ------- |
| Account Lockout Duration            | 10      |
| Account Lockout Threshold           | 7       |
| Reset Account Lockout Counter After | 10      |

---

## 11.3 Audit Policy

All settings: **Success + Failure**

---

## 11.4 User Rights Assignment

| Setting                                         | Allowed |
| ----------------------------------------------- | ------- |
| Access Credential Manager as a trusted caller   | Admin   |
| Access this computer from the network           | No One  |
| Act as part of the operating system             | No One  |
| Add workstations to domain                      | No One  |
| Adjust memory quotas for a process              | No One  |
| Allow log on locally                            | Admin   |
| Allow log on through Remote Desktop Services    | No One  |
| Back up files and directories                   | Admin   |
| Bypass traverse checking                        | No One  |
| Change the system time                          | No One  |
| Change the time zone                            | No One  |
| Create a page file                              | No One  |
| Create a token object                           | Admin   |
| Create global objects                           | Admin   |
| Create permanent shared objects                 | No One  |
| Create symbolic links                           | Admin   |
| Debug programs                                  | No One  |
| Deny access to this computer from the network   | No One  |
| Deny log on as a batch job                      | No One  |
| Deny log on as a service                        | No One  |
| Deny log on locally                             | No One  |
| Deny log on through Remote Desktop Services     | No One  |
| Enable computer and user accounts to be trusted | Admin   |
| Force shutdown from a remote system             | No One  |
| Generate security audits                        | No One  |
| Impersonate a client after authentication       | No One  |
| Increase a process working set                  | No One  |
| Increase scheduling priority                    | Admin   |
| Load and unload device drivers                  | Admin   |
| Lock pages in memory                            | Admin   |
| Log on as a batch job                           | No One  |
| Log on as a service                             | No One  |
| Manage auditing and security log                | Admin   |
| Modify an object label                          | Admin   |
| Modify firmware environment values              | Admin   |
| Perform volume maintenance tasks                | Admin   |
| Profile single process                          | Admin   |
| Profile system performance                      | Admin   |
| Remove computer from docking station            | Admin   |
| Replace a process level token                   | Admin   |
| Restore files and directories                   | Admin   |
| Shut down the system                            | Admin   |
| Synchronize directory service data              | Admin   |
| Take ownership of files or other objects        | Admin   |

---

## 11.5 Security Options

### Administrator Account

* If logged into the **default Administrator**: Enabled
* If using a different account: Disabled

### Guest Account

* Disabled

### Blank Passwords

* Limit local use of blank passwords: **Enabled**

### Account Renames

| Setting              | Action                                            |
| -------------------- | ------------------------------------------------- |
| Rename Admin account | Rename unless currently logged in as that account |
| Rename Guest account | Rename                                            |

### Audit & Logging

* Audit access: **Enabled**
* Audit use of privileges: **Enabled**
* Force audit policy: **Enabled**
* Shutdown computer if security logs cannot be written: **Disabled**

### Machine Access / Launch Restrictions

* Leave **Not Defined** unless explicitly stated.

### Storage & Media

| Setting                                       | Value      |
| --------------------------------------------- | ---------- |
| Allowed to format and eject removable media   | Admin only |
| Prevent users from installing printer drivers | Enabled    |
| Prevent CD-ROM access to local users          | Enabled    |
| Restrict floppy access                        | Enabled    |

### LDAP

* LDAP signing requirements: **Require**

### Machine Account Passwords

| Setting                                  | Value   |
| ---------------------------------------- | ------- |
| Refuse machine account password changes  | Enabled |
| Disable machine account password changes | Enabled |
| Maximum machine password age             | 13 days |
| Require strong session key               | Enabled |

### Login & Access

| Setting                               | Value     |
| ------------------------------------- | --------- |
| Do not display last user name         | Enabled   |
| Do not require CTRL+ALT+DEL           | Disabled  |
| Cached logons                         | 0         |
| Prompt for password before expiration | 8 days    |
| Require domain controller auth        | Disabled  |
| Require smart card                    | Disabled  |
| Smart card removal                    | No action |

### SMB / Network

| Setting                                                       | Value               |
| ------------------------------------------------------------- | ------------------- |
| Digitally sign communications                                 | Disabled (all)      |
| Send unencrypted passwords to SMB servers                     | Disabled            |
| Restrict anonymous access                                     | Enabled             |
| Do not allow anonymous enumeration of SAM accounts            | Enabled             |
| Do not allow anonymous enumeration of SAM accounts and shares | Enabled             |
| Do not allow storage of passwords / creds                     | Enabled             |
| Shares accessible anonymously                                 | **Delete all** text |
| Remotely accessible named pipes                               | **Remove all** text |

### Misc

* Idle time before session suspension: **45 min**

---

# 12. System Restore

1. Right-click **My Computer** → **Properties**
2. Select **System Protection**
3. Configure → Turn on System Protection
4. Set Max Usage → **2 GB**
5. Create a restore point
6. Name it properly
7. Save and confirm

---

# 13. Services

Open MMC → Add **Services** snap-in.

### Key Instructions

* Sort by name
* Compare against default list
* If unsure, verify:

  1. Right-click → **Properties**
  2. Check **Path to Executable**
  3. Cross-check file location and creation date
* Anything with missing description should be treated as suspicious
* Google anything you are unsure about

### Required Service Configurations (Windows 7 Reference)

Below is the corrected & cleaned table.

---

# **Default Services and Their Required Configurations**

| Service Name                                 | Required Configuration |
| -------------------------------------------- | ---------------------- |
| ActiveX Installer                            | Disabled               |
| Adaptive Brightness                          | Disabled               |
| Application Experience                       | Manual                 |
| Application Identity                         | Manual                 |
| Application Information                      | Manual                 |
| Application Layer Gateway Service            | Disabled               |
| Background Intelligent Transfer Service      | Manual                 |
| Base Filtering Engine                        | Automatic              |
| BitLocker Drive Encryption Service           | Manual                 |
| Bitlocker Backup Engine                      | Disabled               |
| Bluetooth Support Service                    | Disabled               |
| Certificate Propagation                      | Disabled               |
| CNG Key Isolation                            | Manual                 |
| COM+ Event System                            | Manual                 |
| COM+ System Application                      | Manual                 |
| Computer Browser                             | Manual                 |
| Credential Manager                           | Manual                 |
| Cryptographic Services                       | Automatic              |
| DCOM Server Process Launcher                 | Automatic              |
| Desktop Window Manager Session Manager       | Automatic              |
| DHCP Client                                  | Automatic              |
| Diagnostic Policy Service                    | Automatic              |
| Diagnostic Service Host                      | Manual                 |
| Diagnostic System Host                       | Manual                 |
| Disk Defragmenter                            | Disabled               |
| Distributed Link Tracking Client             | Manual                 |
| Distributed Transaction Coordinator          | Manual                 |
| DNS Client                                   | Automatic              |
| Encrypting File System                       | Manual                 |
| Extensible Authentication Protocol           | Manual                 |
| Fax                                          | Disabled               |
| Function Discovery Provider Host             | Manual                 |
| Function Discovery Resource Publication      | Manual                 |
| Group Policy Client                          | Automatic              |
| Health Key & Certificate Management          | Manual                 |
| HomeGroup Listener                           | Disabled               |
| HomeGroup Provider                           | Disabled               |
| Human Interface Device Access                | Disabled               |
| IKE & AuthIP IPsec Keying Modules            | Manual                 |
| Interactive Services Detection               | Disabled               |
| Internet Connection Sharing                  | Disabled               |
| IP Helper                                    | Manual                 |
| IPsec Policy Agent                           | Manual                 |
| KtmRm                                        | Disabled               |
| Link-Layer Topology Discovery Mapper         | Manual                 |
| Microsoft .NET Framework NGEN v2.0           | Manual                 |
| Microsoft iSCSI Initiator Service            | Disabled               |
| Microsoft Software Shadow Copy Provider      | Disabled               |
| Multimedia Class Scheduler                   | Disabled               |
| Net.Tcp Port Sharing Service                 | Disabled               |
| Netlogon                                     | Disabled               |
| Network Access Protection Agent              | Manual                 |
| Network Connections                          | Manual                 |
| Network List Service                         | Manual                 |
| Network Location Awareness                   | Manual                 |
| Network Store Interface Service              | Automatic              |
| Parental Controls                            | Disabled               |
| Peer Networking Services (all)               | Disabled               |
| Performance Logs & Alerts                    | Manual                 |
| Plug and Play                                | Disabled               |
| Portable Device Enumerator                   | Disabled               |
| Power                                        | Automatic              |
| Print Spooler                                | Disabled               |
| Problem Reports & Solutions                  | Manual                 |
| Program Compatibility Assistant              | Manual                 |
| Protected Storage                            | Manual                 |
| QWAVE                                        | Disabled               |
| Remote Access Services (all)                 | Disabled               |
| Remote Desktop Services (all)                | Disabled               |
| Remote Procedure Call (RPC)                  | Automatic              |
| Remote Procedure Call Locator                | Manual                 |
| Remote Registry                              | Disabled               |
| Routing & Remote Access                      | Disabled               |
| RPC Endpoint Mapper                          | Automatic              |
| Secondary Logon                              | Disabled               |
| Secure Socket Tunneling Protocol             | Disabled               |
| Security Accounts Manager                    | Automatic              |
| Security Center                              | Automatic              |
| Server                                       | Disabled               |
| Shell Hardware Detection                     | Disabled               |
| Smart Card                                   | Disabled               |
| Smart Card Removal Policy                    | Disabled               |
| SNMP Trap                                    | Disabled               |
| Software Protection                          | Automatic              |
| SSDP Discovery                               | Disabled               |
| Superfetch                                   | Manual                 |
| System Event Notification Service            | Automatic              |
| Tablet PC Input Service                      | Disabled               |
| Task Scheduler                               | Disabled               |
| TCP/IP NetBIOS Helper                        | Disabled               |
| Telephony                                    | Disabled               |
| Telnet                                       | Disabled               |
| Themes                                       | Manual                 |
| Thread Ordering Server                       | Manual                 |
| TPM Services                                 | Disabled               |
| UPnP Device Host                             | Disabled               |
| User Profile Service                         | Automatic              |
| Virtual Disk                                 | Manual                 |
| VMware Services                              | As needed              |
| Volume Shadow Copy                           | Disabled               |
| WebClient                                    | Disabled               |
| Windows Audio                                | Automatic              |
| Windows Audio Endpoint Builder               | Disabled               |
| Windows Backup                               | Manual                 |
| Windows Biometric Service                    | Disabled               |
| Windows Color System                         | Disabled               |
| Windows Connect Now                          | Disabled               |
| Windows Defender                             | Automatic              |
| Windows Driver Foundation                    | Manual                 |
| Windows Error Reporting                      | Manual                 |
| Windows Event Log                            | Automatic              |
| Windows Firewall                             | Automatic              |
| Windows Font Cache                           | Disabled               |
| Windows Image Acquisition                    | Disabled               |
| Windows Installer                            | Manual                 |
| Windows Management Instrumentation           | Automatic              |
| Windows Media Player Network Sharing Service | Disabled               |
| Windows Modules Installer                    | Manual                 |
| Windows Remote Management                    | Disabled               |
| Windows Search                               | Automatic              |
| Windows Time                                 | Manual                 |
| Windows Update                               | Automatic              |
| WinHTTP Web Proxy AutoDiscovery              | Disabled               |
| Wired AutoConfig                             | Manual                 |
| WLAN AutoConfig                              | Manual                 |
| WMI Performance Adapter                      | Disabled               |
| Workstation                                  | Automatic              |
| WWAN AutoConfig                              | Manual                 |

---

## 13.1 Common Non-Default Services to Disable

* SMTP
* Bonjour
* Remote Access Auto Connection Manager
* Remote Access Connection Manager
* Remote Desktop Configuration
* Remote Desktop Services
* Remote Registry
* RIP Routing
* World Wide Web Publishing Service (IIS)
* NetMeeting Remote Desktop Sharing
* Simple File Sharing
* SSDP Discovery
* Windows Messenger Service

---

# 14. Remote Desktop

1. Right-click **My Computer** → Properties
2. Remote tab
3. Advanced
4. Disable:

   * **Allow this computer to be controlled remotely**
   * **Allow Remote Assistance connections**

---

# 15. Automatic Updating

1. Control Panel → System and Security → Windows Update
2. Change Settings
3. Choose: **Install Updates Automatically**

---

# 16. User Account Control (UAC)

1. Control Panel → System and Security → Action Center
2. Change User Account Control Settings
3. Set slider to **Always Notify** (top position)
4. Press OK

---

# 17. Processes and Open Ports

### 1. Check Open Ports

```
netstat -ano
```

### 2. Use Process Explorer

* Enable **Verify Image Signatures**
* Add columns: PID, Company Name, Verified Signature, Image Path

### 3. Default Safe Processes

* System Idle Process
* System
* smss.exe
* csrss.exe
* services.exe
* wininit.exe
* lsass.exe
* winlogon.exe
* dwm.exe
* svchost.exe (verify carefully!)
* explorer.exe
* SearchIndexer.exe

### 4. Killing Malicious Processes

1. Identify path
2. Kill process
3. Navigate to the file location
4. **SHIFT+DELETE** to permanently remove
5. Repeat until system is clean

---

# 18. Programs in Startup

## Windows 7

1. Run → `msconfig` → Startup tab

## Windows 10

Task Manager → Startup

### Only Allowed Startup Items:

* VMware items (if VM)
* Malwarebytes (if installed intentionally)

Disable everything else.

---

# 19. Adding / Removing Windows Components

Control Panel → Programs → Programs and Features → Turn Windows Features On/Off

### Disable:

* Games
* Internet Information Services
* IIS Hostable Web Core
* Media Features
* Print & Document Services
* SNMP
* Telnet Client
* Telnet Server
* TFTP Client/Server
* Windows PowerShell
* XPS Services
* XPS Viewer

(If this is a **host machine**, no server roles should be enabled.)

---

# 20. Disabling Dump File Creation

1. Control Panel → System
2. Advanced System Settings
3. Startup and Recovery → Settings
4. Write Debugging Information → **None**

---

# 21. Saved Windows Credentials

Control Panel → User Accounts → Credential Manager
Delete **all** stored credentials (Windows & Web).

---

# 22. Internet Options — Internet Explorer

1. Open IE
2. Tools → Internet Options
3. Homepage → google.com
4. Browsing history settings → **Never**
5. Delete history on exit → Enabled
6. Security tab → Set all zones to **High**
7. Privacy → Block all cookies
8. Content → Clear SSL Slate
9. Autocomplete → Disable all options
10. Delete autocomplete history

Repeat for all other browsers if applicable.

---

# 23. Power Settings

1. Control Panel → System & Security → Power Options
2. Require Password on Wake → Enabled
3. Sleep settings → adjust advanced options
4. Turn off display after → **1 minute**

---

# 24. Data Execution Prevention (DEP)

Control Panel → System → Advanced → Performance → Settings → DEP tab
Enable:
**Turn on DEP for all programs and services except those I select**
(Leave list empty.)

---

# 25. Malicious Drivers

Use **Uniblue DriverScanner** to detect malicious/outdated drivers.

---

# 26. GMER Scan

Download GMER → Run full scan → Remove rootkits.

---

# 27. Microsoft Baseline Security Analyzer (MBSA)

Run MBSA → Fix all reported security issues.

---

# 28. Service Packs

Only relevant for Windows 7 and older.
Windows 10 does not use service packs.

---

# 29. Updating via Control Panel

Control Panel → System and Security → Windows Update → Check for Updates
Install all critical updates.

---

# 30. Administrative Templates (Advanced Hardening)

