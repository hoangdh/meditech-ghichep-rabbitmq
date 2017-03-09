#!/bin/bash
################################
#
# 1. Cai dat node: doi hostname cho cac host (node1=192.168.100.196)
# 2. Khai bao cac node trong /etc/hosts
# 3. Cai dat RabbitMQ
# 4. Cai dat Cluster
# 5. VIET HAM GEN-KEY TREN NODE CHAY VA TRUYEN VAO 3 NODE
#
#
###############################

###

set_host()
{
. ./var.cfg
echo -e "$IP1 $host1
$IP2 $host2
$IP3 $host3" >> /etc/hosts
for ip in $IP1 $IP2 $IP3
do
    NODE=`cat var.cfg | grep -w "$ip" | awk -F = '{print $1}' | awk -F P {'print $2'}`
    HOST=`cat var.cfg | grep -e "host$NODE" |  awk -F = '{print $2}'`
    hostnamectl set-hostname $HOST -H root@$ip
    echo "Set hostname for host $ip: $NODE - $HOST"
    scp /etc/hosts root@$ip:/etc/
done 
}

setup_rb()
{   
    check_rb=`rpm -qa | grep rabbitmq-server`

    if [ -n "$check_rb" ]
    then
        echo "RabbitMQ has been installed."
        
    else
        bash setup.sh
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
echo "Run command to test: \"rabbitmqadmin list queues name node policy slave_nodes state synchronised_slave_nodes\""
