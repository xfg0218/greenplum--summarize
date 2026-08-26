# 两年磨一剑：PG 19 让逻辑复制 failover 真正可用

> 一个 primary + 3 个 logical subscriber 的电商订单库，跑了一年半没问题。某天主库机房电源故障，备用节点被自动 promote，所有订阅者立刻报「slot does not exist」。45 分钟后业务恢复，期间新订单全部堵塞。
> 这不是段子，是我一个朋友亲历的事故复盘。

逻辑复制 + 高可用，这组搭档从来都不对付。物理备库能扛主库挂了那一刻，逻辑订阅者却指望着主库上的某行内存状态。这条状态写在磁盘上，由 streaming replication 同步它——但偏偏不跟随 WAL。备库拿到 WAL，丢了状态；故障一转，订阅者不知道自己读到哪。

PG 17 之前，每个 DBA 都在绕弯子。pglogical、EnterpriseDB 的 pg_failover_slots、BDR 的私有 fork，都是补丁，补丁之上打补丁。直到 PG 17，内核终于有了完整方案。PG 18 基本没动它。PG 19 把 retry 和统计补齐了——这就是我想讲的两年记。

## 01 真正的根因：slot 为什么跟着不上

逻辑复制 slot 在主库上记录「订阅者消费到哪个 WAL 位置」。这个 restart_lsn 是纯内存对象，定期 dump 到磁盘文件。streaming replication 协议只搬运 WAL，不搬运这个文件。所以备库有 WAL 没有 slot，主库挂了备库顶上时，订阅者接着向新主库请求，那边只有对话记录：

```
ERROR:  replication slot "sub_orders" does not exist
```

想要不丢数据又手动恢复，路径有四条：

1. **停主库 → promote 备库 → 禁用所有 subscription → truncate → 重新建 sub（默认 copy_data=true）→ GB 级数据重传**
2. **用 `pg_failover_slots` 扩展同步状态**（EDB 自家产品，跟社区内核不对齐）
3. **用 BDR**（换架构，单一供应商绑定）
4. **忍着不升级**

Christophe Pettus 在 thebuild.com 写过一段话，意思是：**「Failover slots 是 PostgreSQL 修了十年没修掉的窟窿。17 终于补上了。」** 缺的是 plumbing，逻辑层的拓扑能摆，数据落地的关节始终没人做。这就是问题真正难的地方。

## 02 PG 17 落地的三件套：option、GUC、holdback

PG 17 在主库和备库上各塞进一组开关，缺一不可。

主库侧，subscription（或 slot）上加 `failover = true`：

```sql
-- 创建订阅时直接开启
CREATE SUBSCRIPTION sub_orders
  CONNECTION 'host=primary port=5432 dbname=orderdb user=repl ...'
  PUBLICATION pub_orders
  WITH (failover = true, copy_data = false);

-- 老订阅迁移
ALTER SUBSCRIPTION sub_orders DISABLE;
ALTER SUBSCRIPTION sub_orders SET (failover = true);
ALTER SUBSCRIPTION sub_orders ENABLE;
```

`failover = true` 这个 flag 在主库上是 slot 级别的标记，告诉内核「这个 slot 的状态要让备库知道」。

备库侧，PG 17 多了两个 GUC：

```ini
# postgresql.conf on the standby
primary_slot_name  = 'standby_1'      # 物理复制的物理 slot
hot_standby_feedback = on
primary_conninfo   = '... dbname=postgres ...'  # dbname 必须有
sync_replication_slots = on           # 17 新增，打开自动 sync
```

主库侧第三个 GUC：

```ini
# postgresql.conf on the primary
synchronized_standby_slots = 'standby_1'    # 列出物理 slot 名
```

我接下来说说它为什么是这个名字，而不是 `synchronous_standby_names`。最后再说这个坑。

这三件配齐，整套机制就形成了：

- 主库的 logical slot 把状态写到磁盘
- 备库的 slotsync worker 定期（200ms 起，无变化 backoff 到 30s）通过 libpq 拷过来
- 主库在 `synchronized_standby_slots` 列表里的物理 standby 没收到 WAL 之前，walsender 不把 decoded change 发给 logical subscriber

最后一条是关键，holdback。物理备库跟 logical subscriber 之间由主库做裁判，谁都不能跑赢谁。这就是为什么不是 WAL 内嵌实现——异步拷贝加 holdback 是当时的设计选择，社区讨论里 Robert Haas 解释过，理由是「slot 抽象不应该被物理复制语义绑架」。这话对头，但代价就是这一篇要讲的那些坑。

## 03 PG 18 没有动它，PG 19 改了两个真实痛点

PG 18 那一年没有给这套机制加新东西，只修了一些边角。PG 19 加了两条真实改进，Fujitsu 团队贡献。

第一条，**`pg_sync_replication_slots()` 加 retry 逻辑**。原版只能同步「现在就能同步的 slot」，遇到 WAL 还没到位的 slot，会留个临时副本，下次再试但这次操作相当于失败。commit 0d2d4a0e 把它改成「slot 没准备好就重试」，调用方不需要写循环。官方文档说这是 manual sync 的主要升级——自动 sync 的 worker 本来就在 retry，但诊断脚本常常手动调用这一函数。

第二条，**新增 `skip_stats` 和 skipped-synchronization 统计**。`pg_stat_replication_slots` 和 `pg_replication_slots` 加了几列：

```sql
SELECT slot_name, total_sync_successful, total_sync_failed,
       total_sync_skipped, last_sync_skipped_reason
FROM pg_stat_replication_slots;
```

`last_sync_skipped_reason` 把「这次为什么跳过」写成机器可读的枚举值，常见的有 `wal_not_yet_available`、`walsender_disconnected`、`dbname_missing`。以前这些原因都埋在日志里，看不到失败原因就排不动错。

## 04 那两个名字最像的坑：synchronized 与 synchronous

踩过 failover slots 的人都见过这个报错：

```
ERROR:  replication slot "sub_orders" is being synchronized from the primary
HINT:   The standby is still receiving changes from the primary.
```

表面看是 sync 没完，其实多半是主库的 `synchronized_standby_slots` 名字写错了，或者物理 standby 把它的 slot 名换掉了。Fujitsu 的博客把这事单独拎出来讲：

> 「如果您忘了在 `synchronized_standby_slots` 列出物理 slot 名，那么 logical subscriber 就会跑赢备库。」

`shveta malik` 在 postgres-hackers 上有过一段澄清，引用几句：

> 「如果 `synchronized_standby_slots` 留空（默认），logical subscriber 可能比物理备库跑得更前。一旦 failover，新主库可能没有支撑 logical replication 所需的数据。」

> 「这跟 `synchronous_standby_names` 类似，区别在于它管 logical decoder 是否等。」

我把这两段话抄下来是因为我第一次读 config 的时候也糊涂过：

| 参数 | 作用对象 | 影响范围 |
| --- | --- | --- |
| `synchronous_standby_names` | commit 是否等物理备库 | 应用层延迟（事务提交卡顿） |
| `synchronized_standby_slots` | logical decoder 是否等物理备库 | 复制的 logical consumer 滞后 |

两个参数都可以单独设置。你想要 failover slots 安全但又不想 synchronous commit 时延，配置后者即可。混着用是高时延，不是更安全。

另一个容易混的坑：备库一掉，主库 logical decoding 卡住不动。pg-hackers 上 Fabrice Chapuis 提问过这事，回答是「这是 by design」。如果你只想要 logical failover 安全、不想被物理备库拖死，主库上把 `synchronized_standby_slots` 里这个 slot 移到后面，更稳的办法是从一开始就别把它配到同步拓扑里。

## 05 一个完整的 failover drill

我搭了个两节点 demo：PG 19 + 一个 logical subscriber 订阅 `orders` 表。整套配置改成 failover-aware 走了三个回合。

第一回合，确认订阅带 failover：

```sql
SELECT subname, subfailover FROM pg_subscription;
  subname   | subfailover
--------------+-------------
 sub_orders   | t
(1 row)
```

第二回合，确认备库上看得到「同步好的 slot」：

```sql
-- 在备库执行
SELECT slot_name,
       (synced AND NOT temporary AND invalidation_reason IS NULL) AS failover_ready
FROM pg_replication_slots
WHERE failover;
  slot_name  | failover_ready
--------------+----------------
 sub_orders   | t
(1 row)
```

第三回合，人工 promote 之前跑一次强制 sync：

```sql
-- 在备库执行
SELECT pg_sync_replication_slots();
SELECT restart_lsn, confirmed_flush_lsn
FROM pg_replication_slots
WHERE slot_name = 'sub_orders';
```

如果 `restart_lsn` 与主库侧 `pg_replication_slots.confirmed_flush_lsn` 持平或更新，可以放心 promote。否则歇一秒钟再跑一次（PG 19 自动 retry，旧的版本得手写 sleep）。

PG 19 还提供了捷径——优先看 `pg_stat_replication_slots` 的 `last_sync_state`，如果是 `async` 或 `async_paused`，说明 slotsync worker 跟不上，promote 之前要等。

## 06 几个我碰过的坑

第一个：**表级复制 slot 的同步**。订阅启动时 `copy_data = true` 跑初始同步，主库会为每个表创建 `pg_<suboid>_sync_<relid>_<systemid>` 这种临时 slot。官方文档说初始同步完成后这些 slot 要随主订阅 slot 一起同步到备库，否则 promote 完还得手动重新同步。我在测试时漏配 `hot_standby_feedback = on`，结果临时 slot 进备库后 stale detection 把它回收了，subscribber 重连时报「cannot use replication slot」。记住：临时 slot + `hot_standby_feedback = off` 是常见组合拳，少一步都不行。

第二个：**迁移期 WAL 缺失**。`synchronized_standby_slots` 列出的物理 slot 长时间掉线，重连时 WAL 已被回收，slot sync 就会被 bypass，日志留一行 `synchronization could lead to data loss, because the remote slot needs WAL at LSN 0/3003F28 ...`。这种情况 promote 后只能重建订阅（`copy_data = true`），别挣扎，挣扎没用。

第三个：**`pg_createsubscriber` 的角色**。PG 17 引入的这个工具用来把物理备库转成 logical subscriber，跟 failover slots 不冲突但也容易混——它的方向是「让备库反过来订阅另一个 primary」，跟「让备库接住现有 logical subscriber」的 failover 流程完全不是一回事。

## 07 写在最后

Failover slots 是 PG 内核第一次把逻辑复制放到真正的 HA 语境下考虑，PG 17 引入了整套 plumbing，PG 19 把它打磨成 production-grade。整套机制没有「一行 SQL 解决」的口号，它需要四个 GUC、两个订阅参数、一个物理 slot 配置，但换来的是 PG 17 之前 BDR 才能给的「logical 也能做 failover」能力。

要不要现在就上生产？看你现有副本拓扑是不是 PG 17+，订阅数量多大。我朋友的教训是：等到主库出故障那天才发现自己写过一段 `IF pg_is_in_recovery() { drop subscription; create subscription }` 的 dba 脚本，那是真不行。

## 引用链接

- The Build (Christophe Pettus)：Failover Slots, Two Years On — https://thebuild.com/blog/failover-slots-two-years-on/
- Fujitsu (Ajin Cherian)：Failover slot synchronization in PostgreSQL — https://www.postgresql.fastware.com/blog/failover-slot-synchronization-in-postgresql
- PostgreSQL 官方文档：47.2 Logical Decoding Concepts — https://www.postgresql.org/docs/17/logicaldecoding-explanation.html
- PostgreSQL 官方文档：29.3 Logical Replication Failover — https://www.postgresql.org/docs/17/logical-replication-failover.html
- PostgreSQL 官方文档：19.6 Replication — https://www.postgresql.org/docs/18/runtime-config-replication.html
- pgpedia：`pg_sync_replication_slots()` 文档 — https://pgpedia.info/p/pg_sync_replication_slots.html
- pgsql-hackers：synchronized_standby_slots 与 logical replication 的阻塞行为讨论 — https://www.postgresql.org/message-id/flat/CAA5-nLCKwP3qHUH7z0%3Dbh4Uzwe5Km9T_v5M9mAefp29hMPzTqg@mail.gmail.com
- PostgreSQL 19 Release Notes — https://www.postgresql.org/docs/19/release-19.html
