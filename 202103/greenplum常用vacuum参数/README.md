# Greenplum常用vacuum参数含义
| 参数名字 | 默认值 | 参数中文含义 | 参数英文含义 |
|:----|:----|:----|:----|
| vacuum_cost_delay | 0 | Vacuum cost 代价的延迟（毫秒） | Vacuum cost delay in milliseconds. |
| vacuum_cost_limit | 200 | 导致清理进程休眠的积累开销。 | Vacuum cost amount available before napping. |
| vacuum_cost_page_dirty | 20 | 果清理修改一个原先是干净的块的预计开销。它需要一个把脏的磁盘块再次冲刷到磁盘上的额外开销。 | Vacuum cost for a page dirtied by vacuum. |
| vacuum_cost_page_hit | 1 | 在缓冲区缓存中找到的页的Vacuum成本。 | Vacuum cost for a page found in the buffer cache. |
| vacuum_cost_page_miss | 10 | 在缓冲区缓存中找不到页的vacuum成本 | Vacuum cost for a page not found in the buffer cache. |
| vacuum_freeze_min_age | 100000000 | 指定VACUUM在扫描一个表时用于判断是否用FrozenXID 替换记录的xmin字段(在同一个事务中)。 | Minimum age at which VACUUM should freeze a table row. |
