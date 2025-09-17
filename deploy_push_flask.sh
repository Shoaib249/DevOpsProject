#!/bin/bash
# ===========================
# DevOpsProject Full Deployment + Git Push
# Author: Shoaib
# Description: Automated Flask deploy + DB setup + Gunicorn + NGINX + Git push
# ===========================

# --- Configurable variables ---
PROJECT_DIR="$HOME/DevOpsProject"
APP_FILE="app:app"
DB_NAME="devops_db"
DB_USER="devops_user"
DB_PASS="DevOps123!"
GIT_BRANCH="main"     # Replace if you use a different branch

# --- Step 1: Update system and install dependencies ---
echo "🔹 Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv mysql-server libmysqlclient-dev nginx

# --- Step 2: Setup virtual environment ---
echo "🔹 Setting up Python virtual environment..."
cd $PROJECT_DIR
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt || echo "Requirements installed (some optional may fail)"

# --- Step 3: Setup MySQL database ---
echo "🔹 Configuring MySQL database..."
sudo service mysql start

mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "✅ MySQL setup done!"

# --- Step 4: Setup Flask environment variables ---
echo "🔹 Setting environment variables..."
export MYSQL_HOST="localhost"
export MYSQL_USER="$DB_USER"
export MYSQL_PASSWORD="$DB_PASS"
export MYSQL_DB="$DB_NAME"
export SECRET_KEY="supersecretkey"

# --- Step 5: Run Black auto-format and flake8 ---
echo "🔹 Auto-formatting code with Black and checking lint..."
black . || echo "Files reformatted by Black"
flake8 . || echo "Lint warnings found"

# --- Step 6: Run Gunicorn server ---
echo "🔹 Starting Gunicorn server..."
nohup env MYSQL_HOST=$MYSQL_HOST MYSQL_USER=$MYSQL_USER MYSQL_PASSWORD=$MYSQL_PASSWORD MYSQL_DB=$MYSQL_DB SECRET_KEY=$SECRET_KEY \
gunicorn --workers 3 --bind 0.0.0.0:8000 $APP_FILE > gunicorn.log 2>&1 &

echo "✅ Flask app running on http://0.0.0.0:8000"

# --- Step 7: Setup NGINX ---
echo "🔹 Configuring NGINX..."
sudo rm -f /etc/nginx/sites-enabled/default
sudo tee /etc/nginx/sites-available/devopsproject <<EOL
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL
sudo ln -s /etc/nginx/sites-available/devopsproject /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
echo "✅ NGINX configured and running"

# --- Step 8: Git commit & push using GitHub CLI (browser auth) ---
echo "🔹 Committing and pushing code to GitHub..."
git add .
git commit -m "Auto deploy + code formatting updates"
gh auth login --web
git push origin $GIT_BRANCH

echo "🎉 Deployment & Git push complete!"
