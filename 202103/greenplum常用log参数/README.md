# Greenplum常用log参数含义
| 参数名字 | 默认值 | 参数中文含义 | 参数英文含义 |
|:----|:----|:----|:----| 
| log_autostats | off | 记录发布的自动统计分析的详细信息。 | Logs details of auto-stats issued ANALYZEs. |
| log_autovacuum_min_duration | -1 | 设置记录自动真空操作的最短执行时间。 | Sets the minimum execution time above which autovacuum actions will be logged. |
| log_checkpoints | off | 记录每个checkpoint点。 | Logs each checkpoint. |
| log_connections | off | 记录每个成功连接。 | Logs each successful connection. |
| log_count_recovered_files_batch | 1000 | 记录在每个由该值指定的批大小之后发送到镜像的文件总数 | Logs the total number of files shipped to the mirror after every batch of size specified by this value |
| log_disconnections | off | 记录会话的结束，包括持续时间。 | Logs end of a session, including duration. |
| log_dispatch_stats | off | 将调度程序性能统计信息写入服务器日志。 | Writes dispatcher performance statistics to the server log. |
| log_duration | off | 记录每个完成的SQL语句的持续时间。 | Logs the duration of each completed SQL statement. |
| log_error_verbosity | default | 设置日志消息的详细程度。 | Sets the verbosity of logged messages. |
| log_executor_stats | off | 将执行器性能统计信息写入服务器日志。 | Writes executor performance statistics to the server log. |
| log_hostname | off | 在连接日志中记录主机名。 | Logs the host name in the connection logs. |
| log_lock_waits | off | 记录长时间的锁等待。 | Logs long lock waits. |
| log_min_duration_statement | -1 | 设置记录语句的最短执行时间。 | Sets the minimum execution time above which statements will be logged. |
| log_min_error_statement | error | 导致记录在此级别或以上生成错误的所有语句。 | Causes all statements generating error at or above this level to be logged. |
| log_min_messages | warning | 设置记录的消息级别。 | Sets the message levels that are logged. |
| log_parser_stats | off | 将分析器性能统计信息写入服务器日志。 | Writes parser performance statistics to the server log. |
| log_planner_stats | off | 将计划器性能统计信息写入服务器日志。 | Writes planner performance statistics to the server log. |
| log_rotation_age | 1d | N分钟后将自动旋转日志文件。 | Automatic log file rotation will occur after N minutes. |
| log_rotation_size | 0 | 自动日志文件旋转将在N KB之后发生。 | Automatic log file rotation will occur after N kilobytes. |
| log_statement | all | 设置记录的语句的类型。 | Sets the type of statements logged. |
| log_statement_stats | off | 将累积性能统计信息写入服务器日志。 | Writes cumulative performance statistics to the server log. |
| log_temp_files | -1 | 记录大于此KB数的临时文件的使用情况。 | Log the use of temporary files larger than this number of kilobytes. |
| log_timezone | GMT | 设置要在日志消息中使用的时区。 | Sets the time zone to use in log messages. |
| log_truncate_on_rotation | off | 在日志循环期间截断同名的现有日志文件。 | Truncate existing log files of same name during log rotation.