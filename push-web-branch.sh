#!/bin/bash
# Script to push the web branch to GitHub
# This should be run by someone with push access to the repository

echo "This script will push the 'web' branch to GitHub."
echo "The web branch contains HTML/CSS files for the README documentation."
echo ""

# Check if we're in the right repository
if [ ! -d ".git" ]; then
    echo "Error: Not in a git repository. Please run this from the repository root."
    exit 1
fi

# Check if the web branch exists
if ! git rev-parse --verify web >/dev/null 2>&1; then
    echo "Error: 'web' branch does not exist locally."
    echo "Creating it from copilot/create-web-files-for-readme..."
    git checkout -b web copilot/create-web-files-for-readme
    git checkout copilot/create-web-files-for-readme
fi

echo "Pushing the 'web' branch to origin..."
git push -u origin web

if [ $? -eq 0 ]; then
    echo "✓ Successfully pushed 'web' branch to GitHub!"
    echo "View it at: https://github.com/aidanlenahan/cyberpatriot/tree/web"
else
    echo "✗ Failed to push 'web' branch."
    echo "You may need to authenticate or have the necessary permissions."
fi
