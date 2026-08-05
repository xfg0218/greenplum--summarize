# pg_turbovec 实战案例：从 RAG 到多租户，几条 SQL 搞定向量搜索

> pg_turbovec 的原理和 benchmark 之前聊过了，这次只聊怎么用。六个真实场景，从 RAG 知识库到多租户过滤，从 pgvector 迁移到冷数据压缩，每个场景几条 SQL 就能跑通，强烈推荐边看边试。

## 环境准备

开始前确认环境就绪：

```sql
-- 确认扩展已安装
SELECT extname, extversion FROM pg_extension
WHERE extname IN ('pg_turbovec', 'vector');
--   extname    | extversion
--  pg_turbovec | 1.28.1
--  vector      | 0.8.1

-- 设置 search_path
SET search_path = public, turbovec;
```

没装的参考上一篇文章的安装步骤，几条命令搞定。

## 场景一：RAG 知识库语义搜索

最常见的场景：文档切块 → embedding → 入库 → 语义检索。用 bge-small-en 384 维模型做 demo。

### 建表 + 插入

```sql
-- 创建知识库表
CREATE TABLE knowledge_base (
    id        bigserial PRIMARY KEY,
    title     text,
    content   text,
    embedding turbovec.vector   -- 变长维度，1-16000 维
);

-- 插入文档向量（384 维，bge-small-en）
INSERT INTO knowledge_base (title, content, embedding) VALUES
  ('PG优化器原理', 'PostgreSQL优化器基于代价估算...', '[0.12, 0.45, ...]'),
  ('索引选择策略', '优化器通过统计信息选择索引...', '[0.08, 0.33, ...]'),
  ('WAL机制详解', 'Write-Ahead Logging保证持久性...', '[0.21, 0.67, ...]');

-- 通过 pgvector 风格函数插入
INSERT INTO knowledge_base (title, content, embedding)
VALUES ('MVCC实现', '多版本并发控制...', to_vec('[0.15, 0.52, ...]', 384, false));
```

### 建索引

```sql
-- 4-bit 量化，余弦距离，默认配置
CREATE INDEX kb_emb_idx ON knowledge_base
    USING turbovec (embedding vec_cosine_ops)
    WITH (bit_width = 4);

-- 在线构建（不阻塞写入，生产环境推荐）
CREATE INDEX CONCURRENTLY kb_emb_idx ON knowledge_base
    USING turbovec (embedding vec_cosine_ops)
    WITH (bit_width = 4);
```

### 语义查询

```sql
-- 余弦距离 top-5 检索
SELECT id, title,
       embedding <=> '[0.14, 0.48, ...]'::turbovec.vector AS dist
FROM   knowledge_base
ORDER  BY embedding <=> '[0.14, 0.48, ...]'::turbovec.vector
LIMIT  5;
--  id |      title       |   dist
-- ----+------------------+-----------
--   1 | PG优化器原理     | 0.00231
--   2 | 索引选择策略     | 0.01450
--   4 | MVCC实现         | 0.08920
--   3 | WAL机制详解      | 0.12045
```

### 效果对比

```
# 同样 10000 条 384 维文档，三种方案对比
pgvector HNSW:     索引 21.6 MB,  P95 = 2.87ms
pg_turbovec 4-bit: 索引  6.5 MB,  P95 = 1.92ms  (快 1.5×)
pg_turbovec 2-bit: 索引  3.3 MB,  P95 = 1.88ms, R@10 仍 1.000
```

384 维场景下索引直接省 3 倍，IVF 模式比 HNSW 还快 50%。

## 场景二：多租户向量搜索（内核 allowlist 过滤）

多租户 SaaS 场景：每个租户只能搜自己范围内的文档。传统做法是先 ANN 再过滤，pg_turbovec 直接把过滤推入 SIMD 评分内核。

### 建表 + 插入

```sql
-- 多租户文档表
CREATE TABLE tenant_docs (
    id         bigserial PRIMARY KEY,
    tenant_id  int4 NOT NULL,
    body       text,
    embedding  turbovec.vector
);

-- 插入多租户数据
INSERT INTO tenant_docs (tenant_id, body, embedding) VALUES
  (1, '租户A文档1', '[0.1, 0.2, ...]'),
  (1, '租户A文档2', '[0.3, 0.1, ...]'),
  (2, '租户B文档1', '[0.5, 0.6, ...]'),
  (3, '租户C文档1', '[0.7, 0.8, ...]');
```

### 建索引

```sql
-- 余弦距离 + 4-bit 量化
CREATE INDEX td_emb_idx ON tenant_docs
    USING turbovec (embedding vec_cosine_ops)
    WITH (bit_width = 4);
```

### allowlist 过滤查询

```sql
-- 租户 1 的 top-10 最近邻
SELECT k.id, d.body, k.score
FROM   turbovec.knn(
         'tenant_docs'::regclass,
         'id', 'embedding',
         '[0.15, 0.25, ...]'::turbovec.vector,
         10, 4,                                    -- k=10, bit_width=4
         ARRAY(SELECT id FROM tenant_docs
               WHERE tenant_id = 1)::bigint[]       -- allowlist
       ) k
JOIN   tenant_docs d USING (id)
ORDER  BY k.score DESC;
--  id |     body      |   score
-- ----+---------------+----------
--   1 | 租户A文档1    |  0.99821
--   2 | 租户A文档2    |  0.95340
```

### 为什么 allowlist 比事后过滤快

allowlist 直接推入 SIMD 评分循环。32 向量块中如果没有任何 allowed slot，整个块在 LUT 查找前直接短路跳过。

```
# 选择性过滤性能交叉点
传统 ANN + post-filter:  先取 top-1000 → 再过滤 → 剩 50 条
pg_turbovec allowlist:    SIMD 块内短路 → 直接返回 50 条

# 选择性 10% 时：
传统方式: 评分 1000 个候选 → 过滤剩 100 个
allowlist: 32 向量块整块短路 → 实际评分 ~300 个
# 选择性越低（过滤越严格），allowlist 优势越大
# 交叉点在 ~7-10% 选择性
```

> **关键点**：过滤越严格，pg_turbovec 越快。传统方案是反过来——过滤越严格越慢（因为要取更多候选才能凑够 top-k）。

## 场景三：从 pgvector 迁移

已有 pgvector HNSW 索引，想换 pg_turbovec 省存储。零停机迁移，四步搞定。

### 迁移步骤

```sql
-- Step 1: 添加 pg_turbovec 向量列
ALTER TABLE docs ADD COLUMN embedding_tv turbovec.vector;

-- Step 2: 通过 real[] 桥接转换（pgvector vector → real[] → turbovec.vector）
UPDATE docs SET embedding_tv = embedding::real[]::turbovec.vector;
-- 返回结果：
-- UPDATE 1000000  -- 100万行转换完成

-- Step 3: 在线创建索引（不阻塞写入）
CREATE INDEX CONCURRENTLY docs_emb_tv_idx
    ON docs USING turbovec (embedding_tv vec_cosine_ops)
    WITH (bit_width = 4);

-- Step 4: 切换查询路径
SELECT id, body FROM docs
ORDER  BY embedding_tv <=> $query_vec
LIMIT  10;
```

### 迁移前后对比

```sql
-- 查看迁移前后索引大小
SELECT schemaname, relname, pg_size_pretty(pg_total_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE indexrelname LIKE 'docs_emb%';
--        relname        | index_size
-- ----------------------+------------
--  docs_emb_hnsw_idx    | 10.7 GB    (旧 HNSW)
--  docs_emb_tv_idx      | 780 MB     (新 turbovec 4-bit)
```

```
# 100万条 1536 维 OpenAI embedding 迁移效果
HNSW 索引:  10.7 GB → 磁盘吃满
turbovec:    780 MB → 省了 92%

迁移耗时: ~12 分钟（100万行 real[] 桥接）
索引构建: ~8 分钟（CONCURRENTLY，不阻塞写入）
```

### 灰度切换

```sql
-- 先双跑验证结果一致性
-- 同一查询分别走两个索引
SET enable_indexscan = off;
SET enable_seqscan = off;
-- 强制 turbovec 索引
SELECT id FROM docs ORDER BY embedding_tv <=> $q LIMIT 10;
-- 对比 HNSW 结果
RESET enable_indexscan;
SELECT id FROM docs ORDER BY embedding <=> $q LIMIT 10;

-- 确认结果一致后，删除旧索引
DROP INDEX docs_emb_hnsw_idx;
-- 释放 10.7 GB 磁盘
```

## 场景四：精确+近似混合检索（rerank 重排序）

近似检索快但不够精确？用两阶段：先量化粗筛取 50 个候选，再精确重排取 top-10。

### 基本用法

```sql
-- 两阶段检索：50 个近似候选 → 精确重排 top-10
SELECT *
FROM tq_rerank_candidates(
    'knowledge_base'::regclass,     -- 表名
    'id',                            -- 主键列
    'embedding',                     -- 向量列
    '[0.14, 0.48, ...]'::turbovec.vector,  -- 查询向量
    'cosine',                        -- 距离度量
    50,                              -- 近似候选数
    10                               -- 最终返回数
);
--  id |      title       | rerank_dist
-- ----+------------------+-------------
--   1 | PG优化器原理     | 0.00231
--   2 | 索引选择策略     | 0.01450
--   4 | MVCC实现         | 0.08920
```

### 配合 profile 调优

```sql
-- 低延迟模式（默认）
SET turbovec.profile = 'latency';
-- 4-bit 量化，候选预算适中，P95 最优

-- 高召回模式
SET turbovec.profile = 'high_recall';
-- 扩大候选预算，提高 recall@10

-- 对比两种模式
SET turbovec.profile = 'latency';
SELECT id FROM knowledge_base
ORDER BY embedding <=> '[0.14, 0.48, ...]'::turbovec.vector
LIMIT 10;
-- P95 = 1.27ms, R@10 = 0.836

SET turbovec.profile = 'high_recall';
SELECT id FROM knowledge_base
ORDER BY embedding <=> '[0.14, 0.48, ...]'::turbovec.vector
LIMIT 10;
-- P95 = 2.71ms, R@10 = 0.983
```

### 效果对比

```
# 100万条 dbpedia 1536维 benchmark
引擎/配置               R@10    QPS    平均延迟
pg_turbovec (latency)   0.836   5739   1.27ms
pg_turbovec (high_recall) 0.983  2800  2.71ms
pgvector HNSW            0.979   1770   4.37ms
Qdrant                   0.986    853   9.24ms
Milvus                   0.988    750  10.39ms
```

high_recall 模式下 recall@10 = 0.983，超过 HNSW 的 0.979，QPS 还是 HNSW 的 1.6 倍。

## 场景五：流式写入（实时 embedding ingest）

TurboQuant 零训练，新向量直接量化写入，不需要重建索引。适合实时 embedding 场景。

### 建表 + 实时写入

```sql
-- 创建实时写入表
CREATE TABLE live_embeddings (
    id         bigserial PRIMARY KEY,
    source     text,
    created_at timestamptz DEFAULT now(),
    embedding  turbovec.vector
);

-- 插入时自动归一化
SET turbovec.normalize_on_insert = true;

-- 创建 IVF 索引（支持大规模流式）
CREATE INDEX live_emb_idx ON live_embeddings
    USING turbovec (embedding vec_cosine_ops)
    WITH (bit_width = 4, lists = 100);

-- 模拟实时写入
INSERT INTO live_embeddings (source, embedding)
VALUES ('stream_001', to_vec('[0.12, 0.45, ...]', 384, false));

-- 批量写入（1000条）
INSERT INTO live_embeddings (source, embedding)
SELECT 'batch_' || g, to_vec(array_agg(random())::real[], 384, false)
FROM generate_series(1, 1000) g
GROUP BY g;
```

### 查询 + 诊断

```sql
-- 查询
SELECT id, source
FROM live_embeddings
ORDER BY embedding <=> '[0.14, 0.48, ...]'::turbovec.vector
LIMIT 10;

-- 诊断上次扫描
SELECT * FROM tq_last_scan_stats();
-- 返回 JSON:
-- {
--   "score_mode": "lut16",
--   "simd_kernel": "neon_tbl",      -- ARM NEON 内核
--   "candidates_scored": 2840,
--   "pages_pruned": 12,
--   "ivf_probes": 16
-- }
```

### 索引维护

```sql
-- 大量写入后压实索引
SELECT tq_maintain_index('live_emb_idx');
-- 合并 delta tier，压实索引页

-- 查看索引元数据
SELECT * FROM tq_index_metadata('live_emb_idx');
-- 返回:
--   algorithm_version: v2
--   quantizer_family: turboquant
--   fast_path_eligible: true
--   delta_size: 12 MB
--   recommend_maintain: true
```

### 关键优势

```
# PQ vs TurboQuant 流式写入对比
PQ 方案:
  1. 攒一批数据 → 训练 codebook → 建索引
  2. 新数据分布偏移 → recall 下降 → 重新训练
  3. 语料增长到阈值 → 重建索引

TurboQuant:
  1. 新向量直接量化写入 → 完成
  2. 不看数据，不需要训练
  3. 语料增长，索引自动扩展
```

> 零训练是 TurboQuant 对流式场景最大的价值：不需要攒批、不需要 codebook、不需要重建。

## 场景六：冷数据归档压缩

历史 embedding 数据不常查但占地方？把 HNSW 换成 pg_turbovec 2-bit，存储再砍一半。

### 识别冷数据

```sql
-- 查看各表的向量索引大小
SELECT
    relname,
    pg_size_pretty(pg_total_relation_size(indexrelid)) AS index_size,
    n_tup_ins AS inserts,
    n_tup_upd AS updates,
    idx_scan AS scans_last_stats
FROM pg_stat_user_indexes
WHERE indexrelname LIKE '%emb%'
ORDER BY pg_total_relation_size(indexrelid) DESC;
--      relname      | index_size | inserts | updates | scans
-- -------------------+------------+---------+---------+-------
--  archive_emb_idx   | 62 GB      | 5000000 |       0 |     3  ← 冷数据
--  live_emb_idx      | 780 MB     | 1000000 |  120000 | 45000  ← 热数据
```

archive 表 500 万条数据，scans 只有 3 次——典型冷数据。

### 压缩迁移

```sql
-- 添加 turbovec 列
ALTER TABLE archive_docs ADD COLUMN embedding_tv turbovec.vector;

-- 转换
UPDATE archive_docs SET embedding_tv = embedding::real[]::turbovec.vector;

-- 2-bit 极致压缩索引
CREATE INDEX CONCURRENTLY archive_emb_tv_idx
    ON archive_docs USING turbovec (embedding_tv vec_cosine_ops)
    WITH (bit_width = 2);

-- 验证大小
SELECT pg_size_pretty(pg_total_relation_size(
    (SELECT indexrelid FROM pg_stat_user_indexes
     WHERE indexrelname = 'archive_emb_tv_idx')));
--   pg_size_pretty
--  ----------------
--   195 MB          ← 62 GB → 195 MB，压缩 320×

-- 确认 recall 没废
SELECT * FROM tq_last_scan_stats() ;
-- candidates_scored: 5000000
-- recall_estimate: 1.000   ← 2-bit R@10 仍然是 1.000

-- 删除旧索引
DROP INDEX archive_emb_idx;
```

### 压缩效果

```
# 500万条 1536维 OpenAI embedding 归档
原始 float32:    5000000 × 6144 B = 30 GB
HNSW 索引:       62 GB (含图边开销)
turbovec 4-bit:  5000000 × 772 B = 3.7 GB  (8× 压缩)
turbovec 2-bit:  5000000 × 388 B = 1.9 GB  (32× 压缩, R@10=1.000)

# 总节省: 62 GB → 1.9 GB，一台 8GB 内存的机器就能跑
```

## GUC 调优速查

六个场景通用的 GUC 参数：

```sql
-- 量化精度（2/3/4）
SET turbovec.bit_width_default = 4;    -- 默认 4-bit

-- IVF 探测数（大规模数据调大）
SET turbovec.probes = 32;              -- 默认 16

-- 搜索候选数
SET turbovec.search_k = 64;            -- 默认 32

-- 后端索引缓存
SET turbovec.cache_size_mb = 512;      -- 默认 256

-- 插入时归一化
SET turbovec.normalize_on_insert = true;
```

| GUC | 默认值 | 调优场景 |
|-----|--------|---------|
| `bit_width_default` | 4 | 存储紧张→2，精度优先→4 |
| `probes` | 16 | 数据量大→32-64 |
| `search_k` | 32 | recall 不够→调大 |
| `oversample` | 1.0 | rerank 场景→2.0-3.0 |
| `cache_size_mb` | 256 | 内存够→512-1024 |
| `out_of_core` | auto | 数据超内存→on |

## bit_width 选择决策

| 场景 | bit_width | 存储/1536d | R@10 | 理由 |
|------|-----------|------------|------|------|
| RAG 语义搜索 | **4**（默认） | 780 B | 1.000 | 首选 |
| 内存压力主导 | **2** | 396 B | 1.000 | 极致压缩 |
| 替代 binary_quantize | **2** | 396 B | 1.000 vs 0.65 | 严格更优 |
| 冷数据归档 | **2** | 396 B | 1.000 | 存储优先 |

---

## 六场景速查

| 场景 | 核心操作 | 关键收益 |
|------|---------|---------|
| RAG 知识库 | 建表→建索引→查询 | 索引省 3×，IVF 快 1.5× |
| 多租户过滤 | allowlist 推入 SIMD | 越过滤越快 |
| pgvector 迁移 | real[] 桥接 + CONCURRENTLY | 零停机，省 92% 存储 |
| 精确+近似混合 | tq_rerank_candidates | R@10 = 0.983，QPS 超 HNSW 1.6× |
| 流式写入 | normalize_on_insert + IVF | 零训练，直接量化写入 |
| 冷数据归档 | 2-bit 压缩 | 62GB → 1.9GB，R@10 不掉 |

---

## 不适用场景（诚实说明）

> **不要盲目替换 pgvector HNSW！** 以下场景 pg_turbovec 不是最优解：

| 场景 | 原因 | 建议 |
|------|------|------|
| 需要子线性延迟 | Flat 模式 warm p50 ~2.5s，HNSW 快 ~490× | 留在 HNSW 或用 IVF/Vamana |
| 需要 L2/L1 ANN | `<->` 和 `<+>` 仅精确搜索 | 用 pgvector |
| 需要 halfvec/sparsevec | pg_turbovec 仅支持 f32 | 用 pgvector |
| 维度不是 8 的倍数 | TurboQuant 内核要求 | 需 padding 或换 pgvector |
| 生产级稳定性 | 当前 v1.28.1，API 可能变动 | 等稳定后再上 |

> **两者可在同一数据库干净共存**——独立 schema、独立类型 OID、独立运算符分发表。不用二选一。

### 引用链接

- **pg_turbovec 仓库**：https://codeberg.org/gregburd/pg_turbovec
- **pg_turboquant GitHub**：https://github.com/mayflower/pg_turboquant
- **TurboQuant 论文（ICLR 2026）**：https://arxiv.org/abs/2504.19874
- **turbovec Rust crate**：https://crates.io/crates/turbovec
- **pgvector（对比参照）**：https://github.com/pgvector/pgvector
- **mayflower 博客原文**：https://blog.mayflower.de/29654-turboquant-in-postgresql.html