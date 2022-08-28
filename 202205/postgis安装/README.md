# 软件下载


# 安装依赖的包
```


sudo cat <<EOF > /etc/yum.repos.d/postgis.repo
[postgis]
name=postgis
baseurl=file:///home/pkg-postgis
enabled=1
gpgcheck=0
EOF

rpm -ivh libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm
rpm -ivh unixODBC-2.3.1-14.el7.x86_64.rpm
rpm -ivh proj-4.8.0-4.el7.x86_64.rpm
rpm -ivh proj-devel-5.2.0-32.1.x86_64.rpm


yum install  --disablerepo="*" --enablerepo=postgis -y postgis

--  安装插件
CREATE EXTENSION postgis;

--  查看安装的插件的版本
 \dx postgis
 

 ```