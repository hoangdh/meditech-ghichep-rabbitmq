## Hướng dẫn cài đặt Cluster 3 node cho RabbitMQ trên CentOS 7

### Menu

- [ 1. Chuẩn bị ](#1)
    -   [1.1 Thông tin](#1.1)
    -   [1.2 Một số cấu hình chung](#1.2)
- [ 2. Cấu hình Cluster ](#2)
    - [2.1 Cấu hình trên node thứ nhất](#2.1)
    - [2.2 Cấu hình các node còn lại](#2.2)
    - [2.3 Bật tính năng đồng bộ các queue giữa các node](#2.3)
- [3. Kết luận](#3)

<a name="1"></a>
### 1. Chuẩn bị

<a name="1.1"></a>
#### 1.1 Thông tin 
Thông tin chung

```
OS: CentOS 7
Network: 192.168.100.0/24
Getway: 192.168.100.1
```

Thông tin riêng


Node | Hostname | IP |
---|---|---|
1 | node1 | 192.168.100.196 |
2 | node2 | 192.168.100.197 |
3 | node3 | 192.168.100.198 |

Để cài đặt được cluster cho RabbitMQ trên CentOS, đầu tiên chúng ta phải cài RabbitMQ lên các node. Nếu chưa cài đặt vui lòng tham xem hướng dẫn tại [đây](https://github.com/hoangdh/meditech-ghichep-rabbitmq/blob/master/docs/tutorials/setup-standalone/CENTOS-7.md)

<a name="1.2"></a>
#### 1.2 Một số cấu hình chung

Chúng ta khai báo các hostname của từng node vào DNS Server hoặc sử dụng file `hosts` của từng node

```bash
vi /etc/hosts
```

```
...
192.168.100.196 node1
192.168.100.197 node2
192.168.100.198 node3
```

<a name="2"></a>
### 2. Cấu hình cluster

<a name="2.1"></a>
#### 2.1 Cấu hình trên node thứ nhất

Tiếp theo, sau khi đã cài đặt các node thành công. Chúng ta mở rule của Firewalld để cho các node có thể liên lạc được với nhau. *(Nếu không sử dụng firewall xin bỏ qua bước này.)*

```bash
root@node1# firewall-cmd --add-port={4369/tcp,25672/tcp} --permanent
root@node1# firewall-cmd --reload
```

<a name="2.2"></a>
#### 2.2 Cấu hình trên các node còn lại (node2, node3)

Trên `node2`, chúng ta cấu hình như sau:

Đầu tiên, chúng ta copy cookie từ node1 về và khởi động lại RabbitMQ bằng lệnh:

```bash
root@node2# ssh node1 'cat /var/lib/rabbitmq/.erlang.cookie' > /var/lib/rabbitmq/.erlang.cookie
root@node2# systemctl restart rabbitmq-server
```

Tiếp theo, chúng ta kết nối và gia nhập cluster vào `node1`

```bash
root@node2# rabbitmqctl stop_app 
root@node2# rabbitmqctl reset
root@node2# rabbitmqctl join_cluster rabbit@node1
root@node2# rabbitmqctl start_app
```

Chúng ta kiểm tra đã kết nối thành công bằng lệnh.

```bash
rabbit@node2# rabbitmqctl cluster_status
```

Tương tự, chúng ta cấu hình theo các bước trên `node3`.

<a name="2.3"></a>
#### 2.3 Bật tính năng đồng bộ các queue giữa các node

Trên `node1`, chúng ta sử dụng lệnh sau để cho phép đồng bộ các queue giữa các node với nhau.

```bash
rabbit@node1# rabbitmqadmin declare queue name=shared_queue
rabbit@node1# rabbitmqctl set_policy ha-policy "shared_queue" '{"ha-mode":"all"}'
```

Sau khi cài đặt xong, chúng ta kiểm tra lại bằng lệnh:

```bash
rabbit@node1# rabbitmqadmin list queues name node policy slave_nodes state synchronised_slave_nodes
```
 
<a name="3"></a>
#### 3. Tham khảo

- https://www.server-world.info/en/note?os=CentOS_7&p=rabbitmq&f=4
