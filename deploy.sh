#!/bin/bash

set -e

echo "Starting deployment..."

APP_DIR=/home/ubuntu/flask-react-template

cd $APP_DIR

echo "Pulling latest code..."
git pull origin main

echo "Building React frontend..."
cd frontend
npm ci
npm run build

echo "Copying build to nginx directory..."
sudo cp -r build/* /var/www/html/

echo "Setting up Python backend..."
cd ../backend

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

echo "Stopping existing backend..."
pkill -f gunicorn || true

echo "Starting backend server..."
nohup gunicorn --bind unix:/tmp/app.sock app:app &

echo "Reloading Nginx..."
sudo nginx -s reload

echo "Deployment completed successfully!"
