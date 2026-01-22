# Round 4 (Windows Server 2022 DC-safe scripts)

These scripts are **replacements** for scripts in the root that conflict with a CyberPatriot **Windows Server 2022 Domain Controller** scenario where:
- **RDP must remain enabled** (but only **Domain Admins** may log on via RDP)
- **AD DS / DNS / SMB (SYSVOL/NETLOGON)** must remain available
- Avoid “RunAll” style actions that disable critical services (RDP / Web)

## Scripts

- `rdp-restrict-domain-admins.ps1`
  - Ensures RDP is enabled and firewall rules are on.
  - Restricts **"Allow log on through Remote Desktop Services"** to **Domain Admins**.

- `step4-dc.ps1`
  - Domain-user audit (and optional apply).
  - Creates `authusers-domain.txt` template on first run.
  - By default: **report only**. Use `-Apply` to disable unauthorized AD users and tighten Domain Admin membership.

- `step5-dc.ps1`
  - Disables a small list of commonly-insecure services **without** touching RDP (TermService) or Plug and Play.

- `step6-dc.ps1`
  - Interactive menu of **only** the options that fit this scenario.

## Typical usage

1. Run `step5-dc.ps1` (safe service hardening)
2. Run `rdp-restrict-domain-admins.ps1` (keeps RDP working but limited)
3. Run `step4-dc.ps1` once to generate the auth file, edit it, then rerun with `-Apply` if desired.

All scripts append logs to `C:\CyberPatriot\Logs\` and append diagnostics into `round4\diagnostics\`.
