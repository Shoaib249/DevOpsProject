#!/bin/bash

echo "=== Step 0: Ensure you are in your project directory ==="
pwd

echo "=== Step 1: Remove old SSH keys (if any) ==="
rm -f ~/.ssh/id_ed25519*
echo "Old SSH keys removed (if exist)"

echo "=== Step 2: Generate new SSH key ==="
ssh-keygen -t ed25519 -C "Shoaibkhan100@outlook.com" -f ~/.ssh/id_ed25519 -N ""
echo "SSH key generated: ~/.ssh/id_ed25519"

echo "=== Step 3: Start SSH agent ==="
eval "$(ssh-agent -s)"

echo "=== Step 4: Add SSH key to agent ==="
ssh-add ~/.ssh/id_ed25519
echo "SSH key added to agent"

echo "=== Step 5: Show public key ==="
echo "Copy the following key and add it to GitHub → Settings → SSH and GPG keys → New SSH key:"
cat ~/.ssh/id_ed25519.pub

echo "=== Step 6: Change git remote to SSH ==="
git remote set-url origin git@github.com:Shoaib249/DevOpsProject.git
echo "Git remote set to SSH URL"

echo "=== Step 7: Test SSH connection ==="
ssh -T git@github.com

echo "=== Script finished! After adding public key to GitHub, run: ==="
echo "git push -u origin main"
