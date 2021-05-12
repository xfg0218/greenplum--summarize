# Greenplum监控

#  greenplum_exporter 展示效果图
![image](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum_exporter/greenplum_exporter.png)

# Node Exporter for Prometheus Dashboard 展示效果图

![image](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum_exporter/node_exporter_1.png)
![image](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum_exporter/node_exporter_2.png)


# 1  Prometheus与Grafana简介
	Prometheus官网介绍：https://prometheus.io/
	Grafana官网介绍:  https://grafana.com/
	greenplum_exporter 下载地址：https://github.com/tangyibo/greenplum_exporter
	
	作者分享相关的压缩包:
	链接：https://pan.baidu.com/s/1OCfp7kRC2q52QKfuQud_jA
	提取码：4hsl 
## 1.1 Prometheus 介绍
	Prometheus是由SoundCloud开发的开源监控报警系统和时序列数据库(TSDB)。Prometheus使用Go语言开发，是Google BorgMon监控系统的开源版本。2016年由Google发起Linux基金会旗下的原生云基金会(Cloud Native Computing Foundation), 将Prometheus纳入其下第二大开源项目。

	1)、Prometheus Server， 负责从 Exporter 拉取和存储监控数据，并提供一套灵活的查询语言（PromQL）供用户使用。
	2)、Exporter， 负责收集目标对象（host, container…）的性能数据，并通过 HTTP 接口供 Prometheus Server 获取。
	3)、可视化组件，监控数据的可视化展现对于监控方案至关重要。以前 Prometheus 自己开发了一套工具，不过后来废弃了，因为开源社区出现了更为优秀的产品 Grafana。Grafana 能够与 Prometheus 无缝集成，提供完美的数据展示能力。
	4)、Alertmanager，用户可以定义基于监控数据的告警规则，规则会触发告警。一旦 Alermanager 收到告警，会通过预定义的方式发出告警通知。支持的方式包括 Email、PagerDuty、Webhook 等.
	
## 1.2 Grafana 介绍
	Grafana是一个跨平台的开源的度量分析和可视化工具，可以通过将采集的数据查询然后可视化的展示，并及时通知。它主要有以下六大特点：
	
	1、展示方式：快速灵活的客户端图表，面板插件有许多不同方式的可视化指标和日志，官方库中具有丰富的仪表盘插件，比如热图、折线图、图表等多种展示方式；
	2、数据源：Graphite，InfluxDB，OpenTSDB，Prometheus，Elasticsearch，CloudWatch和KairosDB等；
	3、通知提醒：以可视方式定义最重要指标的警报规则，Grafana将不断计算并发送通知，在数据达到阈值时通过Slack、PagerDuty等获得通知；
	4、混合展示：在同一图表中混合使用不同的数据源，可以基于每个查询指定数据源，甚至自定义数据源；
	5、注释：使用来自不同数据源的丰富事件注释图表，将鼠标悬停在事件上会显示完整的事件元数据和标记；
	6、过滤器：Ad-hoc过滤器允许动态创建新的键/值过滤器，这些过滤器会自动应用于使用该数据源的所有查询。
## 1.3 相关的安装软件下载地址

# 2  Prometheus安装
## 2.1 下载解压
	wget https://github.com/prometheus/prometheus/releases/download/v2.19.2/prometheus-2.19.2.linux-amd64.tar.gz
	
	tar zxvf prometheus-2.19.2.linux-amd64.tar.gz
	mv prometheus-2.19.2.linux-amd64 /usr/local/prometheus
	
## 2.2 创建用户
	groupadd prometheus
	useradd -g prometheus -m -d /var/lib/prometheus -s /sbin/nologin prometheus
	chown prometheus.prometheus -R /usr/local/prometheus
	
## 2.3 创建Systemd服务

	cat > /etc/systemd/system/prometheus.service <<EOF
	[Unit]
	Description=prometheus
	After=network.target
	[Service]
	Type=simple
	User=prometheus
	ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data 
	Restart=on-failure
	[Install]
	WantedBy=multi-user.target
	EOF

## 2.4 启动Prometheus
	
	systemctl daemon-reload
	systemctl start prometheus
	systemctl status prometheus
	systemctl enable prometheus

## 2.5 访问prometheus的web界面
	
	http://IPADDRESS:9090   如果无法访问请查看防火墙是否关闭，
	查看命令systemctl status firewalld.service

# 3 node_exporter节点安装
	node_exporter的作用是用于机器系统数据收集，监控服务器CPU、内存、磁盘、I/O等信息。请在需要监控的服务器上安装。
## 3.1 下载解压
	
	wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
	tar zxvf node_exporter-1.0.1.linux-amd64.tar.gz
	mv node_exporter-1.0.1.linux-amd64 /usr/local/node_exporter
	
## 3.2 创建用户(如果已创建可以忽略)
	
	groupadd prometheus
	useradd -g prometheus -m -d /var/lib/prometheus -s /sbin/nologin prometheus
	chown prometheus.prometheus -R /usr/local/node_exporter
	
## 3.3 创建Systemd服务
	
	cat > /etc/systemd/system/node_exporter.service <<EOF
	[Unit]
	Description=node_exporter
	After=network.target
	[Service]
	Type=simple
	User=prometheus
	ExecStart=/usr/local/node_exporter/node_exporter
	Restart=on-failure
	[Install]
	WantedBy=multi-user.target
	EOF
	
## 3.4 启动node_exporter
	
	systemctl daemon-reload
	systemctl start node_exporter
	systemctl status node_exporter
	systemctl enable node_exporter
	
## 3.5 访问node_exporter的web界面
	http://IPADDRESS:9100   如果无法访问请查看防火墙是否关闭，
	查看命令systemctl status firewalld.service
	
# 4 Grafana安装
	官方地址: https://grafana.com/grafana/download?platform=linux
## 4.1 下载
	wget https://dl.grafana.com/oss/release/grafana-7.0.5-1.x86_64.rpm

## 4.2 安装
	yum install -y grafana-7.0.5-1.x86_64.rpm

## 4.3 配置
	
	配置文件位于/etc/grafana/grafana.ini，这里暂时保持默认配置即可
	
## 4.4 启动
	
	systemctl enable grafana-server
	systemctl start grafana-server

## 4.5访问
	
	http://IPADDRESS:3030   如果无法访问请查看防火墙是否关闭，
	查看命令systemctl status firewalld.service
	
# 5 greenplum_exporter安装
	官网介绍： https://github.com/tangyibo/greenplum_exporter
	
## 5.1 编译go语言环境
	如有相关的版本请跳过该步骤
	
	
	wget https://gomirrors.org/dl/go/go1.14.12.linux-amd64.tar.gz
	tar -C /usr/local -xzf go1.14.12.linux-amd64.tar.gz
	export PATH=$PATH:/usr/local/go/bin
	go env -w GO111MODULE=on
	go env -w GOPROXY=https://goproxy.io,direct
	

## 5.2 编译greenplum_exporter
	
	git clone https://github.com/tangyibo/greenplum_exporter
	cd greenplum_exporter/ && make build
	cd bin && ls -l 
	
## 5.3 启动采集器
	
	export GPDB_DATA_SOURCE_URL=postgres://gpadmin:password@10.17.20.11:5432/postgres?sslmode=disable
	
	./greenplum_exporter --web.listen-address="0.0.0.0:9297" --web.telemetry-path="/metrics" --log.level=error
	
	
	注：环境变量GPDB_DATA_SOURCE_URL指定了连接Greenplum数据库的连接串（请使用gpadmin账号连接postgres库），该连接串以postgres://为前缀，具体格式如下：
	
	
	postgres://gpadmin:password@10.17.20.11:5432/postgres?sslmode=disable
	postgres://[数据库连接账号，必须为gpadmin]:[账号密码，即gpadmin的密码]@[数据库的IP地址]:[数据库端口号]/[数据库名称，必须为postgres]?[参数名]=[参数值]&[参数名]=[参数值]
	
## 5.4 编写一键启动脚本

	配置脚本
	$ vim  start_greenplum_exporter.sh 
	
	$!bin/bash
	
	export GPDB_DATA_SOURCE_URL=postgres://gpadmin:gpadmin@192.168.***.**:5432/postgres?sslmode=disable
	./greenplum_exporter --web.listen-address="192.168.***.:9297" --web.telemetry-path="/metrics" --log.level=error
	
	后台启动脚本
	nohup sh start_greenplum_exporter.sh >> start_greenplum_exporter.log 
	
## 5.5  访问greenplum_exporter的web界面
	http://IPADDRESS:9297/metrics
	
	如果无法访问请查看防火墙是否关闭，查看命令systemctl status firewalld.service

# 6 Prometheus服务端配置
	prometheus的服务端通过pull向各个node_exporter节点端抓取信息，需要在各个node上安装exporter。可以利用 Prometheus 的 static_configs 来拉取 node_exporter 的数据。
## 6.1 编辑prometheus.yml文件 

```shell 
编辑一下文件，主要修改scrape_configs模块即可

# vim  /usr/local/prometheus/prometheus.yml 

# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'gpmaster'
    static_configs:
    - targets: ['192.168.***.***:9100']
  - job_name: 'gpsdw1'
    static_configs:
    - targets: ['192.168.***.***:9100']
  - job_name: 'greenplum_'
    static_configs:
    - targets: ['192.168.48.176:9297']
	
```

## 6.2 重启prometheus
	
	systemctl restart prometheus	

## 6.3 查看新加入的node信息
	http://ADDRESS:9090/targets

# 7 Grafana 配置监控
## 7.1 配置prometheus数据源
	1、登录系统后找到设置->Data Source - > Prometheus数据源 
	2、在HTTP URL 中填写:http://192.168.***.**:9090
	3、测试并保存
	
## 7.2 加载greenplum_exporter监控指标
	1、JSON文件下载地址:  https://grafana.com/grafana/dashboards/13822
	2、把文件导入到grafana中:Manage -- > Import --> Import via panel json(填入下载的JSON文件)

## 7.3 加载node_exporter监控指标
	1、node_exporter的JSON文件下载地址: https://grafana.com/grafana/dashboards/8919
	2、按照以上的步骤加载JSON文件即
