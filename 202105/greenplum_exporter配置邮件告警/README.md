# greenplum_exporter 配置邮件告警
	上一次分享了如何配置《greenplum_exporter监控Greenplum》接下来配置一下对关键指标进行监控，并发送邮件告警

[toc]

# 配置sendmail邮箱
	在以下链接中搜索sendmail下载相关联的文件:
	http://www.rpmfind.net/linux/rpm2html/search.php?query=sendmail&submit=Search+...&system=&arch=
	
# 安装sendmail与mail
	安装sendmail：
	1) 、centos下可以安装命令：yum -y install sendmail
	2) 、安装完后启动sendmail命令：service sendmail start
	
# 安装mail
	安装命令: yum install -y mailx
	
## 设置发件人信息
	上述发送邮件默认会使用linux当前登录用户信，通常会被当成垃圾邮件，指定发件人邮箱信息命令：vi /etc/mail.rc，编辑内容如：
	
	set from=username@126.com
	set smtp=smtp.126.com
	set smtp-auth-user=username
	set smtp-auth-password=password
	set smtp-auth=login
	
	注意配置中的smtp-auth-password不是邮箱登录密码，是邮箱服务器开启smtp的授权码，每个邮箱开启授权码操作不同（网易126邮箱开启菜单：设置-> 客户端授权密码)
	
	
## 重启sendmail
	service sendmail restart
	
## 查看mailx日志
	tail -F  /var/log/maillog

# 邮箱的使用

## 查看帮助
```shell
# mail --help
mail: illegal option -- -
Usage: mail -eiIUdEFntBDNHRV~ -T FILE -u USER -h hops -r address -s SUBJECT -a FILE -q FILE -f FILE -A ACCOUNT -b USERS -c USERS -S OPTION users
```

## 使用mail客户端发送带有内容的邮件
```shell
# echo "这里是邮件内容" | mail -s "这里写邮件标题"  xiaoxu@163.com


或用以下的形式发送邮件
# seq 100 >> test-mail.txt
# mail -s "这里写邮件标题" xiaoxu@163.com < test-mail.txt

```


## 发送带有附件的邮件
```shell
# zip -r test-mail.zip test-mail.txt

# mail -s "这里写邮件标题"xiaoxu@163.com < test-mail.zip
```

# 配置/etc/grafana/grafana.ini文件

``` shell
#################################### SMTP / Emailing ##########################
[smtp]
enabled = true
host = smtp.qq.com:465
user = mail_user
# If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
password = password
;cert_file =
;key_file =
;skip_verify = false
from_address = mail_address
from_name = Grafana
# EHLO identity in SMTP dialog (defaults to instance_name)
;ehlo_identity = dashboard.example.com
# SMTP startTLS policy (defaults to 'OpportunisticStartTLS')
;startTLS_policy = NoStartTLS
[emails]
welcome_email_on_sign_up = false
templates_pattern = emails/*.html



-----------------------------------------

user : 发送邮件的用户名
password : 需要发送邮件的密码，注意这个密码是邮件的授权码
from_address : 发送邮件的地址
from_name : 发送邮件的主体

```

# 重启grafana服务
	
	service grafana-server restart

# 在grafana配置邮件

	1、登录到grafana上:http://ADDRESS:3000/
	2、在Alerting组件上配置一个新的New channel,完成配置，并完成测试
	3、在每个视图中配置邮件即可
	4、查看grafana发送出来的邮件
	
# 配置相关的截图
![image](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum_exporter/Grafana%E9%85%8D%E7%BD%AE%E9%82%AE%E4%BB%B6.png)
![image](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum_exporter/Grafana%E5%9C%A8%E5%B9%B3%E5%8F%B0%E4%B8%8A%E9%85%8D%E7%BD%AE%E9%82%AE%E4%BB%B6.png)
![image](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum_exporter/Grafana%E8%AD%A6%E5%91%8A%E5%88%97%E8%A1%A8.png)
![image](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum_exporter/Grafana%E9%82%AE%E4%BB%B6%E9%85%8D%E7%BD%AE%E6%A1%88%E4%BE%8B.png)






