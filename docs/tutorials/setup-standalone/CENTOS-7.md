## Hướng dẫn cài đặt RabbitMQ trên CentOS 7

### Menu

#### - [ 1. Chuẩn bị ] (#1)
#### - [ 2. Cài đặt ] (#2)
#### - [ 3. Kết luận ] (#3)

### 1. Chuẩn bị

```
OS: CentOS 7
eth0: 192.168.100.196
Network: 192.168.100.0/24
Getway: 192.168.100.1
```

Để cài đặt được RabbitMQ trên CentOS, chúng ta cài đặt trước gói `epel-release`, `wget` và `python` trên server trước.

```
yum install -y epel-release 
yum install -y wget python
```

### 2. Cài đặt

#### 2.1 Cài đặt RabbitMQ
Tiếp theo, chúng ta sẽ sử dụng `yum` để cài đặt RabbitMQ.

```
yum -y install rabbitmq-server
```

Bật và cho RabbitMQ khởi động cùng hệ thống.

```
systemctl start rabbitmq-server 
systemctl enable rabbitmq-server
```

#### 2.2 Cấu hình tường lửa Firewalld

Nếu bạn sử dụng Firewalld, hãy thêm các rule sau:

```
firewall-cmd --add-port=5672/tcp --permanent
firewall-cmd --add-port=15672/tcp --permanent
firewall-cmd --reload
```


#### 2.3 Bật tính năng Web UI

Sử dụng lệnh sau để bật plugin hỗ trợ quản trị qua giao diện Web UI.

```
rabbitmq-plugins enable rabbitmq_management
systemctl restart rabbitmq-server
```

Lấy công cụ quản trị `rabbitmqadmin` được viết bằng `Python` từ `localhost` chỉ khi đã bật Plugin trên và copy nó vào `sbin`.

```
wget http://localhost:15672/cli/rabbitmqadmin
chmod a+x rabbitmqadmin
mv rabbitmqadmin /usr/sbin/
```

Kiểm tra các user đang có trên hệ thống bằng `rabbitmqadmin`:

```
rabbitmqadmin list users
```

#### 2.4 Tạo user trong RabbitMQ

Mặc định khi cài đặt, hệ thống sẽ có một user quản trị mặc định với Username và Password là `guest`.

Tạo user mới có tên là `admin1`, password là `abc@123` và nâng quyền Admin cho nó như sau:

```
rabbitmqctl add_user admin1 abc@123
rabbitmqctl set_user_tags admin1 administrator
```

Phân quyền quản lý cho user ([modify) (write) (read)]

```
rabbitmqctl set_permissions -p / admin1 ".*" ".*" ".*"
```

Xóa user mặc định:

```
rabbitmqctl delete_user guest
```

