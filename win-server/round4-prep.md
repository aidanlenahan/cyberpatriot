# Round 4 Windows Server Preparation
Round 4 this year has two Windows Server images: Windows Server 2019 and Windows Server 2022. One of which is likely to have Active Directory (AD), something I'll have to familiarize myself with.
## Active Directory (AD)
Active Directory is a Windows Server directory service that allows you to manage your domain and series of computers, usually used in enterprise or school environments.
### Structure
There are domains, trees, and forests in Active Directory.
- Domain: group of computers, users, and objects (management)
  - users, computers, applications, printers, shared folders
  - Organizational Units (OU) are used to organize these objects
- Tree - multiple domains (with shared security objects [i.e. Group Policy, Local Security Policy])
- Forest - multiple trees
### Tools for AD
- gpmc.msc (Group Policy Management Console)
  - Allows you to look at Group Policy objects (GPOs), organizational units (OUs), domains, and sites
  - Can configure GPOs for domain(s)
    - **There will be points awarded for securing GPOs in here, such as who can manage AD roles/objects**
- dsa.msc (Active Directory Users and Computers)
  - Manage users
  - Manage computers
To install these tools, go to Server Manager: Quick Start > Add roles and features > Server Roles > Check Active Directory Domain Services > Features > Check Group Policy Management
## First 15 Minutes
1. Check README
  - Look for injects: AD DS, DNS, File Services installed?; users, groups
    - AD must be installed (in Active Directory image)
    - AD depends on DNS; if missing or stopped, AD may not work
  - Critical software: install or update and configure
2. Event Viewer
Event Viewer tells us *why* something is broken, not just that it is broken. Look for:
  1. Windows Logs > System
    - Services failing to start
    - DNS errors
    - Firewall failures
  2. Windows Logs > Security
    - Failed logins
    - Privilige abuse
    - **Disabled auditing**
  3. Applications and Services Logs > Microsoft > Windows
    - Directory Services
    - DNS Server
    - Group Policy
    - CodeIntegrity (WDAC) *(probably overkill)*
  **How to resolve**<br>
  - Read the error message
  - Errors often tell exactly which service or policy is broken
3. Services.msc
  - Services deemed critical in README
  - Windows Defender Antivirus
    > Startup type: Automatic<br>
    > Start Service<br>
    > Re-enable real time protection
  - Windows Firewall
    > **Domain profile must be active**
    > Start service<br>
    > Ensure firewall enabled for Domain profile<br>
    > Go through "Allow an app through firewall"
  - DNS Server *(unlikely as this breaking prevents logging in)*
4. gpresult /r
    > Tells you which GPOs are applied, which are denied, and whether Group Policy is functioning or not<br>
    > **If PowerShell, cmd, Defender, or firewall are disabled, this tells you which GPO disabled them**
## Dealing with Round 4 Hurdles
Of course CyberPatriot Round 4 is not meant to be easy. The AFA tends to add (or remove) things onto the VMs increasingly more throughout the competition season. Since Round 4 is the last "regular season" round, it's by far the hardest (excluding nationals).<br>
That being said, CyberPatriot is known for disabling system services on Round 4, making it harder to get points. In the past they have disabled Powershell, Command Prompt, or both. Reenabling that would make it much easier, that way I could utilize my scripts.
### Reenabling Powershell and Command Prompt
#### Group Policy
Path: ```Computer Configuration → Administrative Templates → Windows Components → Windows PowerShell```
<br><br>
Policies:<br>
- Turn on Script Execution --> Disabled
- Do not allow PowerShell to run --> Enabled
#### AppLocker (via Domain GPO)
#### Windows Defender Application Control (WDAC)
#### Software Restriction Policies
## Points Hunting
