# greenplum 通过mongo_fdw访问mongo数据

## MongoDB 提供了 linux 各发行版本 64 位的安装包，你可以在官网下载安装包
```
curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.2.12.tgz
```

## 解压文件
```
tar -zxvf mongodb-linux-x86_64-3.2.12.tgz
mv mongodb-linux-x86_64-3.2.12 /usr/local/mongodb
```


## 配置环境变量
```
sudo vi /etc/profile
export MONGODB_HOME=/usr/local/mongodb
export PATH=$PATH:$MONGODB_HOME/bin

source /etc/profile
```


## 创建用于存放数据和日志文件的文件夹，并修改其权限增加读写权限
```
cd /usr/local/mongodb
sudo mkdir -p /data/db
sudo chmod -r 777 /data/db
sudo mkdir logscd logs
touch mongodb.log
```


## 添加启动配置文件
```
cd /usr/local/mongodb/bin 
sudo vi mongodb.conf

dbpath = /usr/local/mongodb/data/db 
#数据文件存放目录 
logpath = /usr/local/mongodb/logs/mongodb.log 
#日志文件存放目录 
port = 27017 
#端口 fork = true 
#以守护程序的方式启用，即在后台运行 
nohttpinterface = true
```


## 启动mongod数据库服务，以配置文件的方式启动
```
cd /usr/local/mongodb/bin
./mongod -f mongodb.conf
```


## 连接mongodb数据库
```
./mongo
use mongo_test
db.mongo_test.insert({"warehouse_id" : NumberInt(1),"warehouse_name" : "UPS","warehouse_created" : ISODate("2014-12-12T07:12:10Z")} );
db.mongo_test.find() 
``


# greenplum 访问mongo数据
```
创建外部表信息
drop extension mongo_fdw CASCADE;
create extension mongo_fdw;

CREATE SERVER mx_test FOREIGN DATA WRAPPER mongo_fdw
OPTIONS (address '127.0.0.1', port '27017');

CREATE USER MAPPING FOR mxadmin  SERVER mx_test;

CREATE FOREIGN TABLE mx_mongo
(
        _id name,
        warehouse_id int,
        warehouse_name text,
        warehouse_created timestamptz
)
SERVER mx_test
OPTIONS (database 'mongo_test', collection 'mongo_test');

select * from mx_mongo limit 10;

```


