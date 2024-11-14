# Prompt the user for the file path
Write-Host "`nHashing tool v1.0`n==================`n`n"
$filePath = Read-Host "Please enter the file path"

# Verify the file exists
if (!(Test-Path -Path $filePath)) {
    Write-Host "File does not exist. Please check the path and try again." -ForegroundColor Red
    exit
}

# List available hashing algorithms in PowerShell
$availableHashes = @("MD5", "SHA1", "SHA256", "SHA384", "SHA512", "RIPEMD160")
Write-Host "Available hashing methods:"
$availableHashes | ForEach-Object { Write-Host $_ }

# Prompt the user to select a hashing algorithm
$hashAlgorithm = Read-Host "Enter the hashing method you want to use"

# Validate the input
if ($availableHashes -notcontains $hashAlgorithm) {
    Write-Host "Invalid hashing method selected. Please try again." -ForegroundColor Red
    exit
}

# Compute and display the hash
try {
    $hashValue = Get-FileHash -Path $filePath -Algorithm $hashAlgorithm
    Write-Host "Hash ($hashAlgorithm) for the file:" -ForegroundColor Green
    Write-Host $hashValue.Hash
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
