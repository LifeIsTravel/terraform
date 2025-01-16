#!/bin/bash
${ssh_setting}

echo "${ssh_private_key}" >>/home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh
