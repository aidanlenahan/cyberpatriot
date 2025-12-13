# Branch Update Instructions

This directory contains updated files for the `windows`, `win-server`, and `web` branches.

## Changes Summary

### Windows Branch (`windows/`)
- `README.md` - Added Step 7 (Points Hunting) section with detailed audit tasks
- `step3.ps1` - Changed to use `diagnostics/diagnostics3.txt` with append mode
- `step4.ps1` - Changed to use `diagnostics/diagnostics4.txt` with append mode
- `step5.ps1` - Changed to use `diagnostics/diagnostics5.txt` with append mode
- `step6.ps1` - Changed to use `diagnostics/diagnostics6.txt` with append mode
- `step7.ps1` - Changed to use `diagnostics/diagnostics7.txt` with append mode

### Win-Server Branch (`win-server/`)
- `README.md` - Created detailed README matching Linux format with all step descriptions
- `step1.ps1` - Added diagnostics folder support with append mode
- `step3.ps1` - Added diagnostics folder support with append mode
- `step4.ps1` - Added diagnostics folder support with append mode
- `step5.ps1` - Added diagnostics folder support with append mode
- `step6.ps1` - Added diagnostics folder support with append mode
- `step7.ps1` - Added diagnostics folder support with append mode

### Web Branch (`web/`)
- `windows.html` - Added Step 7 section, updated diagnostics paths
- `win-server.html` - Created detailed guide matching Windows guide format

## How to Apply

For each branch, checkout the branch and copy the corresponding files:

```bash
# Windows branch
git checkout windows
cp branch-updates/windows/* .
git add .
git commit -m "Add Step 7 details, update diagnostics to use folder with append mode"
git push origin windows

# Win-Server branch
git checkout win-server
cp branch-updates/win-server/* .
git add .
git commit -m "Create detailed README, add diagnostics folder support with append mode"
git push origin win-server

# Web branch
git checkout web
cp branch-updates/web/* .
git add .
git commit -m "Add Step 7 to windows.html, create detailed win-server.html"
git push origin web
```

After applying, you can delete this `branch-updates` directory from the main branch.
