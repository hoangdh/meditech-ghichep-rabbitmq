#!/bin/bash

#yum update -y
yum install -y epel-release
yum -y install rabbitmq-server wget python

systemctl start rabbitmq-server 
systemctl enable rabbitmq-server

check_fw=`rpm -qa | grep firewalld`

if [ -n "$check_fw" ]
then
    firewall-cmd --add-port=5672/tcp --permanent
     firewall-cmd --add-port=15672/tcp --permanent
    firewall-cmd --reload
    echo "Firewall has been configured."
fi 

## Create a new user

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
