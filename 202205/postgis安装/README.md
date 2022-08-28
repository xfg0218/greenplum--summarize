# 软件下载
```
链接: https://pan.baidu.com/s/1n8wBX72b3Fba4iv7RE8CDA?pwd=wu4a 提取码: wu4aa

```

# 安装依赖的包
```
-- 解压pkg-postgis
mv pkg-postgis.zip  /home/
unzip pkg-postgis.zip

-- 制作yum repo
sudo cat <<EOF > /etc/yum.repos.d/postgis.repo
[postgis]
name=postgis
baseurl=file:///home/pkg-postgis
enabled=1
gpgcheck=0
EOF

-- 安装依赖
rpm -ivh pkg-postgis/libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm
rpm -ivh pkg-postgis/unixODBC-2.3.1-14.el7.x86_64.rpm
rpm -ivh pkg-postgis/proj-4.8.0-4.el7.x86_64.rpm
rpm -ivh pkg-postgis/proj-devel-5.2.0-32.1.x86_64.rpm

-- 进行安装
yum install  --disablerepo="*" --enablerepo=postgis -y postgis

--  安装插件
CREATE EXTENSION postgis;

--  查看安装的插件的版本
 \dx postgis
 

 ```