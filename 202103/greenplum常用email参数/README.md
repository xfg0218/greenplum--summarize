# Greenplum常用email参数含义
| 参数名字 | 默认值 | 参数中文含义 | 参数英文含义 |
|:----|:----|:----|:----|
| gp_email_connect_avoid_duration | 7200 | 设置避免连接到SMTP服务器的时间量（以秒为单位） | Sets the amount of time (in secs) to avoid connecting to SMTP server |
| gp_email_connect_failures | 5 | 设置在声明SMTP服务器不可用之前连续连接失败的次数 | Sets the number of consecutive connect failures before declaring SMTP server as unavailable |
| gp_email_connect_timeout | 15 | 设置SMTP套接字超时的时间量（秒） | Sets the amount of time (in secs) after which SMTP sockets would timeout |
| gp_email_from |  | 设置电子邮件警报发件人的电子邮件地址(或者email的ID) | Sets email address of the sender of email alerts (our email id). |
| gp_email_smtp_password |  | 设置用于SMTP服务器的密码（如果需要） | Sets the password used for the SMTP server, if required. |
| gp_email_smtp_server | localhost:25 | 设置用于发送电子邮件警报的SMTP服务器和端口 | Sets the SMTP server and port used to send email alerts. |
| gp_email_smtp_userid |  | 设置用于SMTP服务器的用户标识 | Sets the userid used for the SMTP server, if required. |
| gp_email_to |  | 设置要向其发送警报的电子邮件地址。可以是用分号分隔的多个电子邮件地址 | Sets email address(es) to send alerts to.  May be multiple email addresses separated by semi-colon. |