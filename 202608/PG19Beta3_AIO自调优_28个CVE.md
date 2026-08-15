# PostgreSQL 8 月盘点：PG 19 Beta 3、AIO 自调优、28 个 CVE——DBA 这周要做的 5 件事

> 8 月 13 日 PG 全球开发组一次发了 **19 Beta 3 + 5 个维护版本 + 28 个 CVE 修复**。但真正需要这一周就动手的，不是发版本身，而是几个藏在新特性里的"运维习惯切换"。

从昨晚到现在，PostgreSQL 社区的热闹程度有点反常——Beta 3、维护更新、安全公告、CVE 全挤到了同一天。**别只盯着"PG 19 正式版什么时候 GA"**，这几天真正决定你下半年工作量的，是几条被吵过去的运维动作：

- **AIO 调优模型变了**：PG 19 给了 `io_min_workers / io_max_workers` 这套弹性区间，PG 18 上你手动调过的 worker 数大概率该扔了。
- **UUIDv7 不是个好玩的新函数**：它是改写 B-tree 主键设计的关键。
- **pgvector 0.8 已经迭代到 0.8.6**：filtered-recall 的"悬崖"问题在生产里悄悄解决了一大半。
- **pgAdmin 9.18 必须升**：CVSS 9.6 的 RCE 不是演习。
- **PG 14 EOL 倒计时**：距离 **11 月 12 日** 还剩不到 90 天。

下面把这 5 件事拆开讲，每一件都给出命令 + 数据 + 该做什么。

---

## 一、PG 18.6 / 17.11 / 16.15 / 15.19 / 14.24：28 个 CVE 里最该警惕的 3 个

官方公告写的是 **"most alarming pattern is the proliferation of heap buffer overflows and type confusion bugs triggered by low-privileged or unauthenticated attackers"**。

一句话：**多个 CVSS 8.8 的洞，不需要高权限就能 RCE**。

抽 3 个值得贴墙上的：

| CVE | CVSS | 触发条件 | 影响面 |
|-----|------|---------|--------|
| **CVE-2026-14664** | 8.8 | `regexp` 匹配/切分函数，传入无效编码文本 | 堆缓冲区溢出 → 任意代码执行 |
| **CVE-2026-14680** | 8.8 | 任何能调 SQL 函数的用户 | `internal` 参数类型混淆 → RCE |
| **CVE-2026-16239** | 8.8 | `CLOSE` + `DECLARE` 重建游标 | 游标生命周期类型混淆 → RCE |
| CVE-2026-6471 | – | 任意复制用户加载解码插件 | 受 `output_plugin_libraries` 白名单控制 |

> **CVE-2026-14680 根因**：PG 的"internal"参数本来是给 C 函数内部用的，不打算让 SQL 调。安全网关只检查了一部分，剩下那部分漏了，被一个合法用户就拿到了 OS 权限。EPSS 给到的 30 天利用概率是 **0.16%**（低），但 **一旦出 PoC，会瞬间拉满**——这种洞最危险的不是现在，是 30 天以后。

更新后还得做两件事，**不然后面 EXPLAIN 会一直给你假数据**：

```sql
-- 1. 检查并行 GIN 构建 bug 是否把 reltuples 写成了 Infinity / NaN
--    这两个值会让 VACUUM 和 ANALYZE 永远跳过这张表
SELECT relname, reltuples::text
FROM pg_class
WHERE reltuples::text IN ('Infinity', '-Infinity', 'NaN');

-- 2. 如果装了 btree_gist / ltree，对可能涉及 float/NaN/bit 列的索引全部 REINDEX
REINDEX INDEX CONCURRENTLY my_idx;
```

> **不要原地重启了事**：上述 `reltuples` 异常如果出现，光升级版本没用，不 `ANALYZE` 永远不修。

---

## 二、AIO 自调优：PG 19 给 PG 18 的所有调优建议判了"半死刑"

PG 18 加 AIO 时，社区流传一份"worker 数量 = CPU 线程数 / 4"的调优指南。**PG 19 Beta 3 上这份指南该收起来了**。

新参数 `io_min_workers` 和 `io_max_workers` 把 worker 池从"静态池"改成了"弹性池"。默认范围 `[2, 8]`，按查询压力自动扩缩：

```sql
-- postgresql.conf
io_method = worker
io_min_workers = 3   -- 保底值，永远不缩到这以下
io_max_workers = 12  -- 上限，不会扩过这；8 核机器就别拉到 32 了
```

最关键的是 **`EXPLAIN (ANALYZE, IO)`**——它现在能告诉你每个计划节点的 async I/O 实际发了多少请求、回写多少字节、到底有没有重叠：

```sql
EXPLAIN (ANALYZE, IO)
SELECT * FROM events
WHERE created_at > now() - interval '7 days';
```

**拿这一招先抓出"假装在 AIO 的查询"**：

```sql
-- 任何 wait_event = AioWorkerSubmissionQueue 持续 > 100ms 的 session
-- 都说明 worker 池被打满了，PG 自己 fallback 到同步 I/O 了
SELECT pid, wait_event_type, wait_event, state, query_start, query
FROM pg_stat_activity
WHERE wait_event = 'AioWorkerSubmissionQueue';
```

**3 个落地建议**：

1. **PG 18 上手动改过 `io_workers` 的，把那条 postgresql.conf 删了**——19 上限值还是要设，但下限别自己拍脑袋。
2. **优先 `io_method = worker`**：跨平台，PGD 官方包都支持；`io_uring` 快但要 5.x+ 内核 + 容器 seccomp 没屏蔽掉才行。
3. **`sync` 选项留着**：当 A/B 测试出现奇怪回归时切回去排除干扰。

> Christophe Pettus（PGX CEO）的判断比较扎心：*"PG 19 最影响生产行为的变更不是头条特性，是 `jit=off` 默认打开和 64 位 MultiXactOffset 退役这种"静默翻转"。分析型负载上个月"白嫖"JIT 的，可能下个月就掉链子。*

---

## 三、`uuidv7()`：替换 `gen_random_uuid()` 的隐藏价值

PG 18 把 `uuidv7()` 加进了核心函数。表面看就是个"升级版 UUID"，实际它是给一类经典反模式画了终止符：

```sql
-- 老配方：UUIDv4 全随机，B-tree 索引频繁分裂，写入缓存命中率差
CREATE TABLE orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now()
);

-- PG 18+：前 48 bit 是毫秒级时间戳，新行基本按时间顺序落 B-tree 叶子
-- 索引紧凑、缓存友好、近似顺序整数的写入表现
CREATE TABLE orders (
  id uuid PRIMARY KEY DEFAULT uuidv7(),
  created_at timestamptz NOT NULL DEFAULT now()
);
```

**量化推演**：1000 万行订单表，每次插入新行：

- `uuidv4`：随机写入 → B-tree 频繁 page split → 缓存命中率 ~60% → `INSERT` p95 大约 **18 ms**
- `uuidv7`：近似顺序写入 → 缓存命中率 ~92% → 同硬件 `INSERT` p95 大约 **4 ms**

> 实际上 `gen_random_uuid()` 出来的 UUIDv4 在高并发写入下，索引膨胀可能比表本身还夸张——这才是用 `uuidv7()` 的真正理由。

**3 个落地建议**：

1. **新表主键直接用 `uuidv7()`**；老表别回头改，迁移成本不抵收益。
2. **多机房去中心化场景仍可放心**：UUIDv7 后 80+ bit 仍是随机，碰撞概率依然几乎为 0。
3. **要兼顾"严格全局递增"的场景**：用 `uuidv7()` + 一个分区键（比如 `tenant_id` 拼前面），可以把热点打散。

---

## 四、`pgvector` 0.8.6：filtered-recall 的悬崖被悄悄抹平了

5 月底那一波 `pgvector` 0.8.6 修复列表里有一条不起眼的：**并行 HNSW 构建修复 + IO 调度优化**。它解决的是向量数据库最讨厌的问题——"过滤召回悬崖"。

**复现路径**（在 PG 16 + pgvector 0.8.3 上能稳定触发）：

```sql
-- 500k 条 1536 维 OpenAI 嵌入，pgvector 默认 HNSW
SET hnsw.ef_search = 100;

-- 多租户过滤：要求只查 tenant_id = 42 的文档
SELECT id FROM docs
WHERE tenant_id = 42                       -- 这个过滤器干掉 97% 的候选
ORDER BY embedding <-> query_vec
LIMIT 10;
```

老版本表现：图遍历访问 100 个候选 → 几乎全部属于别的租户 → 过滤后剩不到 10 条 → 召回率掉到阈值以下。**RAG 场景下这就是"明明有正确答案，模型硬说不知道"**。

**0.8.0+ 解法**——迭代扫描：

```sql
SET hnsw.iterative_scan = strict_order;        -- 或者 relaxed_order（更快）
SET hnsw.max_scan_tuples = 20000;              -- 上限防扫太多
```

**几个值得知道的细节**：

- `sparsevec` HNSW 索引上限是 **1000 个非零元素**（存储上限 16000，别搞混）。
- `vector` 类型 HNSW 索引上限是 **2000 维**——OpenAI text-embedding-3-large 是 3072 维，老老实实用 `halfvec(3072)`。
- **找最佳平衡点的命令**：

```sql
-- 跑完扫一遍回收率，结果用 brute-force 算 ground truth，再比对
CREATE EXTENSION IF NOT EXISTS vector;
EXPLAIN (ANALYZE, BUFFERS)
SELECT id FROM docs
WHERE tenant_id = $1
ORDER BY embedding <-> $2
LIMIT 10;
```

**对比 Pinecone**：Timescale 的 `pgvectorscale` 在 **5000 万向量 / 99% 召回**场景下，p95 延迟比 Pinecone 低 **28 倍**，吞吐高 **16 倍**。如果你已经在跑 PG，再单独维护一个向量库的 ROI 不高了。

---

## 五、CloudNativePG 1.29：模块化扩展终于跑通最后一公里

> 这一节给 K8s 上的 PG 运维看。如果你的 PG 还在 VM 上，跳过即可。

CloudNativePG 1.29.1（5 月 8 日发的补丁）干了一件大事：**把扩展镜像从内核镜像里彻底拆出来了**。

```yaml
# cluster.yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: app-db
spec:
  instances: 3
  imageCatalogRef:
    apiVersion: postgresql.cnpg.io/v1
    kind: ImageCatalog
    name: postgresql-catalog
    major: 18

  # 以前要打自定义 image 才能用的扩展，现在列在这里就行
  plugins:
    - name: pgvector
      version: "0.8.0"
    - name: postgis
      version: "3.5"

  storage:
    size: 100Gi
```

**好处**：

- **不再"全家桶"镜像**：以前要用 pgvector + PostGIS，得自己 build 镜像，供应链审计一大堆；现在 catalog 解耦，集群 YAML 里加一句就完事。
- **HBA 动态化**：`podSelectorRefs` 让 pg_hba.conf 按标签自动同步短生命周期 Pod 的 IP，K8s 上滚动更新时 HBA 不会滞后。
- **升级不用半夜 cutover**：`pg_upgrade` 加上 PG 18 的"统计信息穿越升级"，主版本升级后立刻有 baseline 性能。

**1.29.1 的安全补丁值得重点升级**（CVE-2026-44477）：

- 旧版 metrics exporter 用 `postgres` 超级用户身份抓指标 → 低权限用户能借此提权到 superuser。
- 1.29.1 后改成专用 `cnpg_metrics_exporter` 角色 + `pg_monitor` 权限。
- **自定义监控查询涉及用户表的，必须给这个新角色显式 `GRANT`**——升级完后查一下监控是否还在工作。

---

## 六、pgAdmin 4：CVSS 9.6 的 RCE 不是开玩笑了

pgAdmin 4 是绝大多数 DBA 的日常工具，所以这次的洞直接关系到你：

| 漏洞 | CVSS | 触发方式 |
|------|------|---------|
| **CVE-2026-17566** | **9.6+** | Import/Export 工具的 SQL 注入 → 主机任意命令执行 |
| CVE-2026-17351 | 9.0 | AI 助手 SQL 注入，绕过只读事务保护 |
| CVE-2026-17348 | 6.9 | 未鉴权路由访问 |

**CVE-2026-17566 技术根因**：pgAdmin 的 `_is_query_parens_balanced()` 校验器还是 **`standard_conforming_strings=off` 的旧假设**——PG 9.1 之后就默认 `on` 了，但这个函数 20 年没改。攻击者构造一个看似平衡的 SQL 串，绕过校验后注入 `TO PROGRAM` 子句，直接打穿到 pgAdmin 主机 shell。

> **行动**：所有 pgAdmin 4 用户**立刻升 9.18**（覆盖 CVE-2026-17566）；至少到 **9.17**（覆盖全 3 个高危）。

`psql` 用户也别放松：CVE-2026-6464 揭示了一个十几年的脚本化注入面——失败回滚的 `COPY ... FROM STDIN` 内联数据被 `psql` 误读。**别再 `psql -f` 跑用户上传的脚本了**。

---

## 七、PG 14 EOL：距离 11 月 12 日还剩不到 90 天

官方原话：**"If you are running PostgreSQL 14 in a production environment, we suggest that you make plans to upgrade to a newer, supported version of PostgreSQL."**

PG 14 最后一次补丁就是 **14.24**——下个月起不再有 CVE 修复。

**升级目标怎么选**：

| 当前版本 | 建议目标 | 主要动力 |
|---------|---------|---------|
| **PG 14** | **18.x** | 已经延了，必须升；跳到 18 拿 AIO + UUIDv7 + Skip Scan |
| **PG 15** | 18.x | AIO / UUIDv7 收益明显 |
| **PG 16** | 18.x 或 19 | 看 Skip Scan 对核心查询是否有命中 |
| **PG 17** | 等 19 或升 18 | 看业务对 REPACK 和 SQL/PGQ 的需求强度 |
| **PG 18** | 18.6 | 已经推荐版本，及时打补丁 |

**升级前 4 个必查**：

```bash
# 1. 扩展兼容性
SELECT extname, extversion FROM pg_extension;

# 2. 提前在 staging 跑 upgrade --check
pg_upgrade --check -d /old/data -D /new/data -b /old/bin -B /new/bin

# 3. 备份 + 验证（必须有次有效备份才能开始）
pg_basebackup -D /backup/full -Ft -z -P

# 4. 准备好回滚脚本（pg_upgrade --swap 是 PG 18 才支持的）
```

> PG 18 的 `pg_upgrade --swap` 是被低估的升级简化器——它交换的是数据目录而不是复制，**主从切换的 30 秒窗口可以从几小时压缩到 30 秒**。

---

## 八、本周 DBA 行动清单（按优先级排）

**今天 / 这两天**：

1. 升级数据库到对应维护版本（18.6 / 17.11 / 16.15 / 15.19 / 14.24）
2. 升级 pgAdmin 到 9.18
3. 检查 `pg_class` 里有没有 `reltuples = Infinity` 的表

**本周内**：

4. PG 18 集群：去掉手写的 `io_workers`，等 19 GA 后用 `io_min/max_workers` 弹性区间
5. 新表主键直接用 `uuidv7()`，老表不返工
6. pgvector 用户：升级到 0.8.6+，RAG 场景强制开 `iterative_scan`
7. K8s 用户：升级 CloudNativePG 到 1.29.1，给自定义监控查询做 `GRANT`

**本月内**：

8. 启动 PG 14 用户的升级项目——11 月 12 日断档日
9. 跟业务对齐 PG 19 GA 后的灰度计划，重点看 REPACK CONCURRENTLY 和 SQL/PGQ
10. RAG / AI 业务：评估用 pgvector 替代独立向量库的 ROI
