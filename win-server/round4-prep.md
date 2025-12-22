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
## Dealing with Round 4 Hurdles
Of course CyberPatriot Round 4 is not meant to be easy. The AFA tends to add (or remove) things onto the VMs increasingly more throughout the competition season. Since Round 4 is the last "regular season" round, it's by far the hardest (excluding nationals).<br>
That being said, CyberPatriot is known for disabling system services on Round 4, making it harder to get points. In the past they have disabled Powershell, Command Prompt, or both. Reenabling that would make it much easier, that way I could utilize my scripts.
### Reenabling Powershell and Command Prompt
