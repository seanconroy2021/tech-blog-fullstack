#!/bin/bash
# Ubuntu 22.04.4 LTS
# These are just overall commands sace in .sh file to run on the EC2 instance

# Update the system's package index
sudo apt update 

# NVM (Node Version Manager) Setup
# Download and execute the NVM installation script
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Set up NVM environment variables
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load nvm bash_completion

# Install a specific Node.js version using NVM
nvm install 21.7.3 

# Clone the Sean Conroy Blog repository
git clone https://github.com/seanconroy2021/tech-blog-fullstack
cd tech-blog-fullstack/

# Install project dependencies
npm install

# Creation of .env for secret variables
# IMPORTANT: In a real-world AWS Secrets Manager would be a more secure approach.
# echo "DB_NAME='blogdb'" > .env
# echo "DB_HOST='hidden'" >> .env
# echo "DB_PORT='3306'" >> .env
# echo "DB_USER='bloguser'" >> .env
# echo "DB_PASSWORD='hidden'" >> .env
# echo "SESSION_SECRET='hidden'" >> .env

# Install PM2 to manage for the  Node.js application
npm install pm2 -g
pm2 start ~/tech-blog-fullstack/server.js --name "Sean Conroy Blog" -i max
pm2 install pm2-metrics # This will be used to monitor the Node App with CloudWatch

# Configure PM2 to auto-start at system boot
pm2 startup
sudo env PATH=$PATH:/home/ubuntu/.nvm/versions/node/v21.7.3/bin /home/ubuntu/.nvm/versions/node/v21.7.3/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 save

# Install AWS CLI for the use of CloudWatch monitoring 
# IMPORTANT: aws configure and only set the region: us-east-1
sudo apt install -y awscli

# Create a cron job to monitor the PM2 metrics
env EDITOR=nano crontab -e
# Add the following line to the crontab file
*/1 * * * * /home/ubuntu/monitoring_CloudWatch_Production.sh
