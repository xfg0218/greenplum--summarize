# 修改Greenplum默认的CST时区
	有时我们在PGCC界面上显示时间相差8个小时，是由于时区配置的不准确造成的，
	按照以下修改即可

	1、中国标准时区(CST)和美国中部时区(CST)重名
	2、GP默认会将CST识别为美国中部时区
	3、导致国内时区为CST的服务器在事件计算时出现意外结果
	4、解决方法
	     4.1 修改GP安装目录下/share/postgresql/timezonesets/Default
	     4.2 在文件的84行找到CST -21600内容，修改为CST -28800
	     4.3 gpstop -u同步Master与Segment之间的配置文件
	     4.4 重新启动GPDB