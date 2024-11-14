#!/bin/bash

# Prompt the user for the file path
read -p "Please enter the file path: " filePath

# Verify the file exists
if [[ ! -f "$filePath" ]]; then
    echo "File does not exist. Please check the path and try again."
    exit 1
fi

# List available hashing algorithms
availableHashes=("md5" "sha1" "sha256" "sha384" "sha512" "ripemd160")
echo "Available hashing methods:"
for hash in "${availableHashes[@]}"; do
    echo "$hash"
done

# Prompt the user to select a hashing algorithm
read -p "Enter the hashing method you want to use: " hashAlgorithm

# Check if the selected algorithm is valid
if [[ ! " ${availableHashes[@]} " =~ " ${hashAlgorithm} " ]]; then
    echo "Invalid hashing method selected. Please try again."
    exit 1
fi

# Compute and display the hash using openssl
hashValue=$(openssl dgst "-$hashAlgorithm" "$filePath" 2>/dev/null)

# Check if openssl successfully computed the hash
if [[ $? -ne 0 ]]; then
    echo "An error occurred. The selected algorithm may not be supported."
    exit 1
else
    echo "Hash ($hashAlgorithm) for the file:"
    echo "$hashValue"
fi
