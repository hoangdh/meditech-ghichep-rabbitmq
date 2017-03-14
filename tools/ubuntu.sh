#!/bin/bash
echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install rabbitmq-server python -y

systemctl start rabbitmq-server 
systemctl enable rabbitmq-server


rabbitmqctl add_user admin1 abc@123
rabbitmqctl set_user_tags admin1 administrator

## Grant permissions to new user

rabbitmqctl set_permissions -p / admin1 ".*" ".*" ".*" 

## Enable web UI

rabbitmq-plugins enable rabbitmq_management
systemctl restart rabbitmq-server

## Install rabbitmqadmin tools

wget http://localhost:15672/cli/rabbitmqadmin
chmod a+x rabbitmqadmin
mv rabbitmqadmin /usr/sbin/
 rabbitmqadmin list users

ip_addr=` ip addr | grep 'state UP' -A2 | tail -n1 | awk -F'[/ ]+' '{print $3}'`
echo -e "Access to Web UI: http://$ip_addr:15672
         Username: admin1
         Password: abc@123"