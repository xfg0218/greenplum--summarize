# Greenplum常用interconnect参数含义
| 参数名字 | 默认值 | 参数中文含义 | 参数英文含义 |
|:----|:----|:----|:----|
| gp_interconnect_cache_future_packets | on | 控制是否缓存将来的数据包. | Control whether future packets are cached. |
| gp_interconnect_debug_retry_interval | 10 | 按重试次数设置间隔，以记录要重试的调试消息. | Sets the interval by retry times to record a debug message for retry. |
| gp_interconnect_default_rtt | 20ms | 设置UDP互连的默认rtt（毫秒） | Sets the default rtt (in ms) for UDP interconnect |
| gp_interconnect_fc_method | LOSS | 设置用于UDP互连的流控制方法。 | Sets the flow control method used for UDP interconnect. |
| gp_interconnect_hash_multiplier | 2 | 设置UDP互连用于跟踪连接的哈希桶数（桶数由段计数和哈希乘数的乘积给出）。 | Sets the number of hash buckets used by the UDP interconnect to track connections (the number of buckets is given by the product of the segment count and the hash multipliers). |
| gp_interconnect_min_retries_before_timeout | 100 | 设置在互联中报告传输超时之前的最小重试次数。 | Sets the min retries before reporting a transmit timeout in the interconnect. |
| gp_interconnect_min_rto | 20ms | 设置UDP互连的最小rto（毫秒） | Sets the min rto (in ms) for UDP interconnect |
| gp_interconnect_queue_depth | 4 | 为UDP互连中的每个连接设置接收队列的最大大小 | Sets the maximum size of the receive queue for each connection in the UDP interconnect |
| gp_interconnect_setup_timeout | 2h | 查询开始时发生的互连设置超时（秒） | Timeout (in seconds) on interconnect setup that occurs at query start |
| gp_interconnect_snd_queue_depth | 2 | 为UDP互连中的每个连接设置发送队列的最大大小 | Sets the maximum size of the send queue for each connection in the UDP interconnect |
| gp_interconnect_tcp_listener_backlog | 128 | 每个TCP互连套接字的侦听队列的大小 | Size of the listening queue for each TCP interconnect socket |
| gp_interconnect_timer_checking_period | 20ms | 设置UDP互连的计时器检查周期（毫秒） | Sets the timer checking period (in ms) for UDP interconnect |
| gp_interconnect_timer_period | 5ms | 设置UDP互连的计时器周期（毫秒） | Sets the timer period (in ms) for UDP interconnect |
| gp_interconnect_transmit_timeout | 1h | 传输数据包的互连超时（秒） | Timeout (in seconds) on interconnect to transmit a packet |
| gp_interconnect_type | UDPIFC | 设置用于节点间通信的协议。 | Sets the protocol used for inter-node communication. |