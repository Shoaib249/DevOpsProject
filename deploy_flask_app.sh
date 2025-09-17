#!/bin/bash
# deploy_flask_app.sh
# Usage: ./deploy_flask_app.sh

set -e

PROJECT_DIR=~/DevOpsProject
APP_FILE=app.py
VENV_DIR=$PROJECT_DIR/venv
DB_NAME=devops_db
DB_USER=devops_user
DB_PASS=DevOps123!   # tumhare hisaab se change kar sakte ho

echo "🔹 Updating system & installing packages..."
sudo apt update && sudo apt install -y python3-venv python3-pip nginx mysql-server libmysqlclient-dev

echo "🔹 Setting up MySQL server..."
sudo systemctl start mysql
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "🔹 Setting up virtual environment & dependencies..."
python3 -m venv $VENV_DIR
source $VENV_DIR/bin/activate
pip install --upgrade pip
pip install -r $PROJECT_DIR/requirements.txt
pip install gunicorn

echo "🔹 Stopping any running Gunicorn..."
pkill gunicorn || true

echo "🔹 Starting Gunicorn..."
nohup gunicorn --workers 3 --bind 127.0.0.1:8000 $PROJECT_DIR/$APP_FILE &

echo "🔹 Configuring NGINX..."
sudo tee /etc/nginx/sites-available/devopsproject <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/devopsproject /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

echo "✅ Deployment complete!"
echo "📌 Access your app at http://<your-VM-IP>/"
echo "MySQL credentials -> DB: $DB_NAME, User: $DB_USER, Pass: $DB_PASS"
