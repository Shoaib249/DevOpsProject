#!/bin/bash
# fix_code.sh — Flask project code auto-fix

echo "Running Black to auto-format files..."
black . 

echo "Checking lint with flake8..."
flake8 .

echo "All done! ✅"
echo "Agar Black ne files reformat ki, commit karke push kar dena."
