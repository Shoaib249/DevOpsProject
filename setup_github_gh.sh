#!/bin/bash

# 1. Check if gh CLI is installed
if ! command -v gh &> /dev/null
then
    echo "gh CLI not found. Installing..."
    sudo apt update
    sudo apt install gh -y
else
    echo "gh CLI is already installed. Version:"
    gh --version
fi

# 2. Authenticate GitHub via browser
echo "Starting GitHub authentication via browser..."
gh auth login

# 3. Set git remote to HTTPS if not already
echo "Setting git remote URL to HTTPS (if needed)..."
git remote set-url origin https://github.com/Shoaib249/DevOpsProject.git

# 4. Test push
echo "Testing push to GitHub..."
git push -u origin main
