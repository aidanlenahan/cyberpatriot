# CyberPatriot Image Hardening Guides
**NOTE: Archived October 2026. This repo was a private resource I had developed during my time as a Cyberpatriot competitor, but that time is over, so I thought I'd make it a public archive. See my CyberPatriot experience [here]([https://aidanlenahan.com/blog/articles/](https://aidanlenahan.com/blog/articles/cyberpatriot). Enjoy!**


---

These guides provide a step-by-step approach to hardening CyberPatriot images for security. Each step includes specific tasks and scripts aimed at improving the security posture of the system.

---

## Windows Guide
This Windows guide is written in PowerShell. The extended version can be found [here](https://github.com/aidanlenahan/cyberpatriot/tree/windows).

| Step | Name | Description |
|------|------|-------------|
| 0 | Initial Setup | Create required groups, users, and install necessary programs |
| 1 | Initialization | Set execution policy, enable hidden files, show file extensions |
| 2 | Forensics | Use tools like CyberChef, ChatGPT, Cryptii for forensics questions |
| 3 | Basic Security | Enable firewall, Windows Defender, remove bad shares and unwanted files |
| 4 | Users and Groups | Disable unauthorized users, manage admin group, disable Guest/Administrator |
| 5 | Services | Disable unnecessary services (Remote Registry, RDP, FTP, SNMP, etc.) |
| 6 | Miscellaneous | Disable RDP, check open ports, enable auto-updates, apply security policies |
| 7 | Points Hunting | Check suspicious processes, open ports, FTP services, scheduled tasks, disable SMBv1 |

---

## Windows Server Guide
This Windows Server guide is written in PowerShell. The extended version can be found [here](https://github.com/aidanlenahan/cyberpatriot/tree/win-server).

| Step | Name | Description |
|------|------|-------------|
| 0 | Initial Setup | Create required groups, users, and install necessary programs |
| 1 | Initialization | Set execution policy, enable hidden files, show file extensions |
| 2 | Forensics | Use tools like CyberChef, ChatGPT, Cryptii for forensics questions |
| 3 | Basic Security | Enable firewall, Windows Defender, remove bad shares and unwanted files |
| 4 | Users and Groups | Disable unauthorized users, manage admin group, disable Guest/Administrator |
| 5 | Services | Disable unnecessary services (Remote Registry, RDP, FTP, SNMP, etc.) |
| 6 | Miscellaneous | Disable RDP, check open ports, enable auto-updates, apply security policies |
| 7 | Points Hunting | Check suspicious processes, open ports, FTP services, scheduled tasks, disable SMBv1 |

---

## Linux Guide
This Linux guide is written in Bash. The extended version can be found [here](https://github.com/aidanlenahan/cyberpatriot/tree/linux).

| Step | Name | Description |
|------|------|-------------|
| 0 | Initial Setup | Create required groups, users, and install necessary programs |
| 1 | Initialization | Configure file manager, document system state, create backups |
| 2 | Forensics | Use tools like CyberChef, ChatGPT, Cryptii for forensics questions |
| 3 | Basic Security | Enable firewall, automatic updates, scan for media files and unwanted apps |
| 4 | Users and Groups | Disable unauthorized users, manage sudo permissions, configure password policies |
| 5 | Services | Disable unnecessary services (FTP, Telnet, rsync), secure SSH |
| 6 | Miscellaneous | Interactive menu for additional security configurations |
| 7 | Points Hunting | Comprehensive security audit including processes, ports, cron jobs, SUID files |
| 8 | PAM Configuration | Configure password complexity and account lockout (run last!) |

---

## Legacy Scripts
The [`legacy/`](legacy) folder holds my original CyberPatriot scripts, which used to live in my [dev](https://github.com/aidanlenahan/dev) repository. I brought them here so all of my CyberPatriot work is in one place. They're kept as they were and are not maintained.

| Path | Contents |
|------|----------|
| [`legacy/batch/`](legacy/batch) | Early batch scripts: change all user passwords (`allPwdChange.bat`), apply/analyze a security template with `secedit` (`secApply.bat`, `sec-analysis.inf`), and reference links in `source/` |
| [`legacy/powershell/masterbible24-25/windows/`](legacy/powershell/masterbible24-25/windows) | The 2024-25 "master bible" Windows guide, the predecessor to the guides above |
| [`legacy/powershell/all-passwd.ps1`](legacy/powershell/all-passwd.ps1) | Turns off "Password never expires" and sets one password for all local users |
| [`legacy/powershell/firewall-simple.ps1`](legacy/powershell/firewall-simple.ps1) | Basic Windows Firewall setup for all profiles, with logging |
| [`legacy/powershell/password-expires.ps1`](legacy/powershell/password-expires.ps1) | Turns off "Password never expires" for all enabled local users |

---

## Note
This repository extends its predecessor, which can now be found in [`legacy/powershell/masterbible24-25/windows`](legacy/powershell/masterbible24-25/windows). This evolved from just another coding project to a bigger project which has become much more helpful and useful than I initially thought, so I put it in its own repository.

---

## License
This guide is designed for use in CyberPatriot competitions and may be adapted for other cybersecurity competitions or educational purposes.
