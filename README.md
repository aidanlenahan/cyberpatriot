# Cyberpatriot
This repository contains guides and scripts for both Windows and Linux. Scroll down for Linux image hardening.


# Windows CyberPatriot Image Hardening

This guide provides a step-by-step approach to hardening a Windows CyberPatriot image for security. Each step includes specific tasks and scripts aimed at improving the security posture of the system. Below is an overview of the steps, resources, and tasks involved.

[Source Document](https://docs.google.com/document/d/e/2PACX-1vT2zjA8CaPWgSmMfjuAQXL91jd2ioXfFl3J_zvzhtXNg7lFbNFENRbakHlqrodOCvrJ8hJ_O5YRnCyt/pub)

---

## Step 0 - Initial Setup
### Tasks:
- **Create Required Groups:** Set up the necessary user groups.
- **Create Required Users:** Create the required user accounts.
- **Install Necessary Programs:** Ensure all required software is installed on the system.

---

## [Step 1 - Initialization](https://raw.githubusercontent.com/aidanlenahan/dev/refs/heads/main/ps/cyberpatriot/masterbible24-25/windows/step1.ps1)
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

---

## Step 2 - Forensics Tools
### Recommended Resources:
- **CyberChef**
- **ChatGPT**
- **Cryptii**
- **GitHub Copilot**

---

## [Step 3 - Basic Security](https://raw.githubusercontent.com/aidanlenahan/dev/refs/heads/main/ps/cyberpatriot/masterbible24-25/windows/step3.ps1)
### Tasks:
1. **Enable Firewall:**
   - Ensure the firewall is turned on.
2. **Enable Real-Time Protection:**
   - Verify that real-time protection is enabled.
3. **Remove Bad Shares:**
   - Remove any unnecessary network shares (except `ADMIN$`, `IPC$`, and `C$`).
4. **Remove Unwanted Software:**
   - Uninstall unnecessary or insecure software, including:
     - Wireshark, CCleaner, Npcap, PC Cleaner, Network Stumbler, L0phtCrack, JDownloader, Minesweeper, and other games.
5. **Remove Unwanted Files:**
   - Delete unnecessary media and document files, including:
     - Audio/Video: mp3, mp4, mov, wav, aac, flac, mkv
     - Images: png, jpeg, jpg, gif, tiff, bmp
     - Documents: pdf, doc, docx
6. **Configure In-Browser Security:**
   - Use the most secure DNS and ensure HTTPS is always used.

---

## [Step 4 - Users and Groups](https://raw.githubusercontent.com/aidanlenahan/dev/refs/heads/main/ps/cyberpatriot/masterbible24-25/windows/step4.ps1)
### Tasks:
1. **Disable Unauthorized Users:**
   - Use **Computer Management** to disable any unauthorized users.
2. **Verify Admin Group Settings:**
   - Ensure the "Password Never Expires" option is turned **OFF** for all admin users.
3. **Disable Guest and Administrator Accounts:**
   - Make sure both the **Guest** account and **Administrator** account are disabled.

#### How to Execute This Script:
1. **Run the script `step4.ps1` first.** It will create a template file named `authusers.txt` in the same directory.
2. **Format the user list:** Use ChatGPT with the provided prompt to convert the readme user list into the format recognized by the script.
3. **Copy ChatGPT’s Output to `authusers.txt`.**
4. **Run `step4.ps1` again** to apply changes.
5. **Check `diagnostics4.txt`** for updates.

---

## [Step 5 - Services](https://raw.githubusercontent.com/aidanlenahan/dev/refs/heads/main/ps/cyberpatriot/masterbible24-25/windows/step5.ps1)
### Tasks:
- **Disable Unnecessary Services:** Disable the following services:
  - Remote Registry
  - Remote Desktop Services
  - Telephony
  - FTP (Windows FTP)
  - SNMP Trap
  - SMTP
  - Infrared Monitor Service
  - Plug and Play

---

## [Step 6 - Miscellaneous](https://raw.githubusercontent.com/aidanlenahan/dev/refs/heads/main/ps/cyberpatriot/masterbible24-25/windows/step6.ps1)
### Tasks:
1. **Disable All RDP (Remote Desktop Protocol):**
   - Ensure RDP is disabled to prevent remote access vulnerabilities.
2. **Check for Open Ports:**
   - Identify and close any unnecessary open ports.
3. **Enable Automatic Windows Updates:**
   - Configure updates through **Group Policy Editor (gpedit.msc)**.
4. **Apply Windows Security Policies (SecPol):**
   - Use **MMC** (Microsoft Management Console) to configure security policies with `.inf` files.

---

## License
This guide is designed for use in CyberPatriot competitions and may be adapted for other cybersecurity competitions or educational purposes.
