<#
.SYNOPSIS
    An interactive tool to calculate the hash of a file.

.DESCRIPTION
    This script prompts the user for a file path and a hashing algorithm, then calculates and displays the file's hash.
    It can also take the file path as a parameter. The results of the hashing operation are logged to a transcript.

.PARAMETER FilePath
    The path to the file to be hashed.

.NOTES
    Author: Gemini
    Date: 2025-11-15
#>
[CmdletBinding()]
param(
    [string]$FilePath
)

# Start logging
$LogPath = "C:\CyberPatriot\Logs"
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}
Start-Transcript -Path "$LogPath\hashing-log.txt" -Append

try {
    Write-Host "`nHashing tool v2.0`n==================" -ForegroundColor Cyan

    if (-not $FilePath) {
        $FilePath = Read-Host "Please enter the file path"
    }

    if (!(Test-Path -Path $FilePath)) {
        Write-Host "File does not exist: $FilePath" -ForegroundColor Red
        return
    }

    Write-Verbose "File found: $FilePath"

    $availableHashes = @("MD5", "SHA1", "SHA256", "SHA384", "SHA512", "RIPEMD160")
    Write-Host "Select a hashing algorithm:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $availableHashes.Count; $i++) {
        Write-Host "$($i+1): $($availableHashes[$i])"
    }

    $choice = Read-Host "Enter the number of your choice"
    $index = [int]$choice - 1

    if ($index -lt 0 -or $index -ge $availableHashes.Count) {
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }

    $hashAlgorithm = $availableHashes[$index]
    Write-Verbose "User selected algorithm: $hashAlgorithm"

    $hashValue = Get-FileHash -Path $FilePath -Algorithm $hashAlgorithm
    Write-Host "Hash ($hashAlgorithm) for '$FilePath':" -ForegroundColor Green
    Write-Host $hashValue.Hash
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Verbose "Hashing script finished."
    Stop-Transcript
}
