#!/bin/bash

# Config
APP_DIR="/home/UbuntuMachine/DevOpsProject"
VENV_DIR="$APP_DIR/venv"
APP_MODULE="app:app"
PORT=80

echo "Checking if port $PORT is in use..."
PID=$(sudo lsof -t -i:$PORT)

if [ ! -z "$PID" ]; then
    echo "Port $PORT is in use by PID: $PID. Killing process..."
    sudo kill -9 $PID
    sleep 1
fi

echo "Starting Gunicorn server..."
cd $APP_DIR
sudo $VENV_DIR/bin/gunicorn --bind 0.0.0.0:$PORT $APP_MODULE
