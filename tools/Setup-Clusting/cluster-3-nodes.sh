#!/bin/bash
################################
#
# Script configure Clusting RabbitMQ for 
# 3 nodes on CentOS 7
#   - Step 1: Generate key SSH for 3 nodes
#   - Step 2: Setup RabbitMQ
#   - Step 3: Configure clusting
# Author: HoangDH - h2pro9x
# (C) HoangDH - MediTech JSC,.
# Publish: 10/3/2017
#################################

set_host()
{
. ./var.cfg
### Write to hosts
echo -e "$IP1 $host1
$IP2 $host2
$IP3 $host3" >> /etc/hosts
### Gen-key
ssh-keygen -t rsa -N "" -f ~/.ssh/hoangdh.key
mv ~/.ssh/hoangdh.key.pub ~/.ssh/authorized_keys
mv ~/.ssh/hoangdh.key ~/.ssh/id_rsa
chmod 600 ~/.ssh/authorized_keys

for ip in $IP1 $IP2 $IP3
do
    NODE=`cat var.cfg | grep -w "$ip" | awk -F = '{print $1}' | awk -F P {'print $2'}`
    HOST=`cat var.cfg | grep -e "host$NODE" |  awk -F = '{print $2}'`
    scp -r ~/.ssh/ $HOST:~/
    # hostnamectl set-hostname $HOST -H root@$HOST
    ssh $HOST "hostnamectl set-hostname $HOST"
    echo "Set hostname for host $ip: $NODE - $HOST"
    scp /etc/hosts root@$HOST:/etc/
done

}
rabbitmq()
{
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

}
setup_rb()
{   
    check_rb=`rpm -qa | grep rabbitmq-server`

    if [ -n "$check_rb" ]
    then
        echo "RabbitMQ has been installed."            
    else
        rabbitmq
    fi 
}

### Node Master
config_fw()
{
    check_fw=`rpm -qa | grep firewalld`

    if [ -n "$check_fw" ]
    then
       firewall-cmd --add-port={4369/tcp,25672/tcp} --permanent
       firewall-cmd --reload
       echo "Firewall has been configured."
fi 
}

### Sync queues on master

sync_queue()
{
    rabbitmqadmin declare queue name=shared_queue
    rabbitmqctl set_policy ha-policy "shared_queue" '{"ha-mode":"all"}'
}

copy_cookie()
{
    ### $1: IP Master
    ssh $1 'cat /var/lib/rabbitmq/.erlang.cookie' > /var/lib/rabbitmq/.erlang.cookie
    systemctl restart rabbitmq-server
    rabbitmqctl stop_app 
    rabbitmqctl reset
    rabbitmqctl join_cluster rabbit@$1
    rabbitmqctl start_app
    rabbitmqctl cluster_status
}

set_host
for ip in $IP1 $IP2 $IP3
do
    NODE=`cat var.cfg | grep -w "$ip" | awk -F = '{print $1}' | awk -F P {'print $2'}`
    HOST=`cat var.cfg | grep -e "host$NODE" |  awk -F = '{print $2}'`
    if [ "$NODE" == "1" ]
        then
            ssh $HOST "$(typeset -f); setup_rb"
            ssh $HOST "$(typeset -f); config_fw"
        else
            ssh $HOST "$(typeset -f); setup_rb"
            ssh $HOST "$(typeset -f); copy_cookie $host1"
    fi
done 
ssh $host1 "$(typeset -f); sync_queue"
echo -e "- Run command to test: \"rabbitmqadmin list queues name node policy slave_nodes state synchronised_slave_nodes\"
- Node remote: \"ssh node1 rabbitmqadmin list queues name node policy slave_nodes state synchronised_slave_nodes\"
"