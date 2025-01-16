#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y openssh-server

# Add the SSH public key to authorized_keys
echo "${ssh_public_key}" >>/home/ubuntu/.ssh/authorized_keys

sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh