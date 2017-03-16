## Hướng dẫn sử dụng

[1. Giới thiệu ](#1)

[2. Yêu cầu](#2)

[3. Các bước thực hiện](#3)

<a name="1"></a>
### 1. Giới thiệu

Script này sẽ giúp các bạn cài đặt và cấu hình tự động Cluster 3 node cho RabbitMQ trên [CentOS 7](docs/tutorials/setup-cluster/cluster-centos.md) hoặc [Ubuntu 16](https://github.com/meditechopen/meditech-ghichep-rabbitmq/blob/master/docs/tutorials/setup-cluster/cluster-ubuntu.md). Các bạn có thể xem bài hướng dẫn cài đặt bằng tay để hiểu rõ hơn quá trình làm việc của script.

<a name="2"></a>
### 2. Yêu cầu:

- Các file cấu hình `conf.cfg`, script `cluster-3-nodes.sh` và phải nằm trong cùng một thư mục.

*Script có thể chạy trên một máy bất kỳ hoặc trên 1 trong 3 node đáp ứng đủ các yêu cầu trên..*

<a name="3"></a>
### 3. Các bước thực hiện

- **Bước 1**: Khai báo thông tin các node của bạn vào file `conf.cfg` theo mẫu:

    ```
    host1=node1
    host2=node2
    host3=node3
    
    IP1=192.168.100.196
    IP2=192.168.100.197
    IP3=192.168.100.198
    ```
    
    **Chú thích**:
    - `IP1` là địa chỉ IP của node 1
    - `IP2` là địa chỉ IP của node 2
    - `IP3` là địa chỉ IP của node 3
    - `host1` là hostname của node 1
    - `host2` là hostname của node 2
    - `host3` là hostname của node 3
    
- **Bước 2**: Kiểm tra lại các file cấu hình `var.cfg`, script `cluster-3-nodes.sh` trong thư mục

- **Bước 3**: Phân quyền chạy cho script
    
    ```
    chmod 755 cluster-3-nodes.sh
    ```
- **Bước 4**: Chạy script

    ```
    ./cluster-3-nodes.sh
    ```
    
*Chúc các bạn thành công!*