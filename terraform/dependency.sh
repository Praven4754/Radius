#!/bin/bash
set -e

# Update package index
sudo apt update -y

# Install prerequisites
sudo apt install -y ca-certificates curl gnupg lsb-release software-properties-common

# Add Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker & Compose
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Create app folder
sudo mkdir -p /home/ubuntu/app

# Move Docker Compose YAML and .env file
sudo mv /tmp/compose3.yml /home/ubuntu/app/docker-compose.yml
sudo mv /tmp/.env /home/ubuntu/app/.env
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

# Print versions
docker --version
docker compose version
