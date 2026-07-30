# pg_turbovec：让 PostgreSQL 向量搜索存储直降 20 倍，还不掉召回

> 1000 万条 1536 维 OpenAI embedding，pgvector HNSW 要吃 62 GB 磁盘。pg_turbovec 只要 4 GB——而且 R@10 一样是 1.000。这不是魔法，是数学。

## 01 问题根源：pgvector 的内存墙

搞 RAG 的都遇到过这个问题：文档量一上千万，pgvector 的 HNSW 索引就变成了内存怪兽。

```
# 1000 万 × 1536 维 OpenAI embedding 存储成本
FP32 原始向量：    62 GB
pgvector HNSW：    ~62 GB（索引 ≈ 原始数据）
pgvector halfvec： ~31 GB
pgvector 1-bit：   ~3.9 GB（R@10 只有 0.65-0.75，基本不可用）
```

三条死路：

| 方案 | 存储 | R@10 | 问题 |
|------|------|------|------|
| HNSW 原始精度 | ~62 GB | 0.96-0.99 | 内存吃不起 |
| halfvec 降精度 | ~31 GB | ≈1.0 | 还是太大 |
| binary_quantize | ~3.9 GB | 0.65-0.75 | 召回率废了 |

核心矛盾：**1-bit 量化只保留符号，丢掉了幅度信息**。4 个 bucket 的 Lloyd-Max 量化比 2 个 bucket 的符号阈值更接近 Shannon 失真率下界——但 pgvector 没有 2-bit/4-bit 标量量化。

pg_turbovec 就是来填这个坑的。

## 02 扩展原理：TurboQuant 为什么能压 16 倍还不掉召回

pg_turbovec 基于 Google Research 的 TurboQuant 算法（ICLR 2026 论文），用 Rust 实现，通过 pgrx 框架封装成 PostgreSQL 扩展。

核心机制 5 步：

```
1. 归一化（Normalize）
   剥离 L2 范数，存为单个 f32 缩放因子
   每个向量变成单位球面上的一个方向

2. 随机旋转（Random Rotation）
   乘以固定正交矩阵
   旋转后每个坐标独立遵循已知 Beta 分布 → 收敛到 N(0, 1/d)
   关键：分布是数学已知的，不需要从数据中学习

3. Lloyd-Max 标量量化
   对已知分布预计算最优桶边界
   2-bit = 4 个桶，4-bit = 16 个桶
   可证明失真率最优（provably distortion-rate-optimal）

4. 位打包（Bit-pack）
   dim 个坐标 → dim × bit_width / 8 字节
   1536 维：6144 B → 388 B（2-bit）/ 772 B（4-bit）

5. 长度重归一化评分
   每向量额外一个标量，消除量化器引入的内积向下偏差
```

**和 PQ 的本质区别：**

| 特性 | FAISS PQ | TurboQuant |
|------|----------|------------|
| 训练 | 需要 k-means 训练 codebook | **零训练** |
| 数据遍历 | 需要采样训练 | **零遍历** |
| 语料增长 | 可能需要重建索引 | **直接插入，无需重建** |
| 失真率 | 接近但不最优 | **匹配 Shannon 下界** |

翻译成人话：PQ 要先看数据才能学会怎么压缩，TurboQuant 用数学证明了旋转后的分布是已知的，直接算最优边界——不需要学。

## 03 安装

前置要求：PostgreSQL 13-18、Rust ≥ 1.96。

```bash
# 安装 pgrx 工具链
cargo install --locked cargo-pgrx --version 0.19.1

# 初始化 pgrx 开发环境
cargo pgrx init

# 克隆并编译
git clone https://codeberg.org/gregburd/pg_turbovec
cd pg_turbovec
cargo pgrx install --release
```

验证安装：

```sql
-- 启用扩展
CREATE EXTENSION pg_turbovec;
SET search_path = public, turbovec;

-- 验证
SELECT extname, extversion FROM pg_extension WHERE extname = 'pg_turbovec';
-- 返回结果：
--   extname     | extversion
--  pg_turbovec  | 1.28.1
```

## 04 使用方法

### 创建表 + 插入数据

```sql
-- 创建向量表（变长维度，1-16000 维）
CREATE TABLE items (
    id        bigserial PRIMARY KEY,
    body      text,
    embedding turbovec.vector
);

-- 插入数据（三种方式）
INSERT INTO items (body, embedding) VALUES
  ('hello', '[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]'),
  ('world', '[0.2, 0.1, 0.4, 0.3, 0.6, 0.5, 0.8, 0.7]');

-- 通过数组转换
INSERT INTO items (body, embedding)
VALUES ('greeting', ARRAY[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8]::real[]::turbovec.vector);

-- 通过 pgvector 风格函数
INSERT INTO items (body, embedding)
VALUES ('hi', to_vec('[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8]', 8, false));
```

> **维度限制：** `vector` 类型支持 1-16000 维，但 TurboQuant 内核要求维度为 8 的倍数（384 = 48×8 ✓，1536 = 192×8 ✓）。

### 最近邻查询

```sql
-- 余弦距离排序（语义搜索最常用）
SELECT id, body,
       embedding <=> '[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8]'::turbovec.vector AS dist
FROM   items
ORDER  BY embedding <=> '[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8]'::turbovec.vector
LIMIT  5;

-- 支持的 4 种距离运算符
-- <->  L2 欧氏距离（仅精确搜索）
-- <#>  负内积（支持索引，默认操作符类 vec_ip_ops）
-- <=>  余弦距离（支持索引，vec_cosine_ops）
-- <+>  L1 曼哈顿距离（仅精确搜索）
```

### 创建索引

```sql
-- 余弦距离索引（4-bit 量化，默认）
CREATE INDEX items_emb_idx ON items
    USING turbovec (embedding vec_cosine_ops)
    WITH (bit_width = 4);

-- 2-bit 极致压缩（存储再减半，R@10 仍 1.000）
CREATE INDEX items_emb_2bit_idx ON items
    USING turbovec (embedding vec_cosine_ops)
    WITH (bit_width = 2);

-- 在线构建（不阻塞写入）
CREATE INDEX CONCURRENTLY items_emb_idx ON items
    USING turbovec (embedding vec_cosine_ops);
```

### 过滤搜索：内核 allowlist

这是 pg_turbovec 最硬核的功能之一——**过滤在 SIMD 内核里做，不是事后过滤**。

```sql
-- Top-10 最近邻，限定租户范围
SELECT k.id, d.body
FROM   turbovec.knn(
         'items'::regclass,
         'id', 'embedding',
         '[...]'::turbovec.vector,
         10, 4,                              -- k=10, bit_width=4
         ARRAY(SELECT id FROM items WHERE tenant_id = $1)::bigint[]  -- allowlist
       ) k
JOIN   items d USING (id)
ORDER  BY k.score DESC;
```

allowlist 直接推入 SIMD 评分循环：32 向量块中如果没有任何 allowed slot，整个块在 LUT 查找前直接短路。**选择性过滤变得更便宜而非更昂贵**，交叉点在 ~7-10% 选择性。

## 05 效果对比

### 存储压缩（1M × 1536-d 真实 OpenAI embeddings）

| 方案 | 每向量磁盘 | 1M 总存储 | 压缩比 |
|------|-----------|----------|--------|
| FP32 原始 | 6,144 B | ~6 GB | 1× |
| pgvector HNSW | 8,192 B | ~8 GB | 0.75×（索引比原始还大） |
| pgvector halfvec | 3,072 B | ~3 GB | 2× |
| **pg_turbovec 4-bit** | **772 B** | **~780 MB** | **8×** |
| **pg_turbovec 2-bit** | **388 B** | **~390 MB** | **16×** |
| pgvector binary_quantize | 192 B | ~192 MB | 32× |

### 召回率（1M dbpedia，真实 OpenAI ada-002）

| 方法 | Bytes/行 | R@10 | 能用？ |
|------|----------|------|--------|
| FP32（ground truth） | 6,144 | 1.000 | ✅ |
| **TurboQuant 4-bit** | 780 | **1.000** | ✅ |
| **TurboQuant 2-bit** | 396 | **1.000** | ✅ |
| 1-bit + Hamming HNSW | 192 | 0.65-0.75 | ❌ |

> **2-bit 模式只用 396 字节，R@10 仍然是 1.000**——同字节预算下，binary_quantize 只有 0.65-0.75。

### 搜索速度（TurboQuant 论文基准）

| 硬件 | 对比对象 | turbovec 表现 |
|------|----------|--------------|
| ARM M3 Max（NEON） | FAISS IndexPQFastScan | **快 12-20%** |
| x86 Sapphire Rapids（AVX-512BW） | FAISS IndexPQFastScan | 4-bit 配置领先 1-6% |
| x86 2-bit 单线程 | FAISS | 差距 ±1% 以内 |

### 冷扫描加速（pg_turbovec 专属优化）

pg_turbovec 通过 buffer manager 直接读取索引数据（无 tmpfile 中转），实测冷扫描加速 **21 倍**：

```
# 1M × 1536-d OpenAI ada-002 语料，单机基准测试
优化前（tmpfile 中转）：26,310 ms (p50)
优化后（buffer 直读）：  1,256 ms (p50)
加速比：21×
```

## 06 bit_width 选择指南

| 工作负载 | 推荐 bit_width | 存储/1536-d | R@10 | 说明 |
|---------|---------------|-------------|------|------|
| RAG/语义搜索，R@10 ≥ 0.95 | **4**（默认） | 780 B | 1.000 | 首选 |
| 内存压力主导，R@10 ≥ 0.85 | **2** | 396 B | 1.000 | 极致压缩 |
| 替代 binary_quantize | **2** | 396 B | 1.000 vs 0.65 | 严格更优 |
| pgvector 等价召回，减半存储 | halfvec（不量化） | 3,072 B | ≈1.0 | 不用 pg_turbovec |

## 07 三种索引类型

| 索引类型 | 命令 | 延迟特点 | 适用场景 |
|---------|------|---------|---------|
| **Flat**（默认） | `USING turbovec` | O(n·dim) 全扫描 | 中小规模，精确召回 |
| **IVF** | `WITH (lists = N)` | cell 裁剪扫描，out-of-core | 大规模，延迟敏感 |
| **Vamana 图** | `WITH (graph = true)` | 导航图 ANN，低延迟 | 中等规模，低延迟需求 |

> **诚实说明：** Flat 模式在 1M 行时 warm p50 约 2.5s，pgvector HNSW（子线性图）快约 490 倍。**pg_turbovec 不在裸 flat 延迟上击败 HNSW**。但 IVF 模式实测 1M × 1536-d warm p50 约 17-24ms（R@10 0.84-0.89），是实用的延迟配置。

## 08 适用场景

**选 pg_turbovec 的场景：**

1. **存储受限的语义搜索**——余弦/内积搜索，磁盘/内存是瓶颈
2. **千万级 RAG pipeline**——1000 万文档从 62GB 压到 4GB，单机就能跑
3. **需要精确召回重排**——xs_recheckorderby 机制，先量化粗筛再精确重排
4. **选择性过滤搜索**——allowlist 在 SIMD 内核短路，过滤越严格越快
5. **不想碰 codebook 训练**——零训练，在线 ingest，语料增长无需重建索引
6. **Postgres 原生 ACID 需求**——和业务数据 JOIN、事务一致

**选 pgvector + HNSW 的场景：**

1. 需要原始 HNSW 子线性延迟
2. 需要 L2/L1 ANN（pg_turbovec 仅支持精确 L2/L1）
3. 需要 halfvec/sparsevec/bitvec
4. 无内存压力，重视生态成熟度

> **两者可在同一数据库干净共存**——独立 schema、独立类型 OID、独立运算符分发表。

## 09 从 pgvector 迁移

```sql
-- 1. 添加 pg_turbovec 向量列
ALTER TABLE docs ADD COLUMN embedding_tv turbovec.vector;

-- 2. 通过 real[] 桥接转换
UPDATE docs SET embedding_tv = embedding::real[]::turbovec.vector;

-- 3. 在线创建索引
CREATE INDEX CONCURRENTLY docs_emb_tv_idx
    ON docs USING turbovec (embedding_tv vec_cosine_ops)
    WITH (bit_width = 4);

-- 4. 切换查询
SELECT id, body FROM docs
ORDER  BY embedding_tv <=> $query_vec
LIMIT  10;
```

## 10 限制说明

> **不要在生产环境盲目替换 pgvector！** pg_turbovec 目前有以下限制：

| 限制项 | 说明 |
|--------|------|
| **不支持 halfvec / sparsevec / bit** | 仅支持 `f32` 的 `vector` 类型 |
| **不支持 L2/L1 ANN** | `<->` 和 `<+>` 仅精确搜索，不能走索引 |
| **不是 pgvector 直接替代品** | by design，两者共存 |
| **Flat 延迟不如 HNSW** | 需要 IVF 或 Vamana 图才能获得实用延迟 |
| **版本尚早** | 当前 v1.28.1，API 可能变动 |
| **维度必须是 8 的倍数** | TurboQuant 内核要求 |
| **varlena 二进制兼容未完成** | 1.0 路线图项，目前需 `real[]` 桥接 |

### 18 个 GUC 调优参数

```sql
-- 会话级调整示例
SET turbovec.bit_width_default = 2;     -- 量化精度
SET turbovec.probes = 32;                -- IVF 探测数
SET turbovec.search_k = 64;              -- 搜索候选数
SET turbovec.cache_size_mb = 512;        -- 后端本地索引缓存
SET turbovec.normalize_on_insert = true;  -- 插入时归一化
```

| GUC | 默认值 | 说明 |
|-----|--------|------|
| `bit_width_default` | 4 | 量化精度 2/3/4 |
| `probes` | 16 | IVF 探测数 |
| `search_k` | 32 | 搜索候选数 |
| `oversample` | 1.0 | 过采样倍数 |
| `out_of_core` | auto | 超内存时磁盘扫描 |
| `cache_size_mb` | 256 | 后端本地索引缓存 |
| `normalize_on_insert` | true | 插入时归一化 |

## 11 技术架构：双 crate 设计

```
┌─────────────────────────────────────────┐
│           PostgreSQL 查询引擎            │
│  ORDER BY emb <=> q LIMIT k            │
│  → turbovec Index AM (ambeginscan)     │
├─────────────────────────────────────────┤
│         pg_turbovec (pgrx 扩展)          │
│  · vector 类型 / 运算符 / 聚合           │
│  · turbovec Index AM (CRUD + VACUUM)    │
│  · buffer manager 直读（无 mmap）        │
│  · allowlist 过滤推入 SIMD 循环          │
├─────────────────────────────────────────┤
│         turbovec (Rust crate)            │
│  · TurboQuant 编码管线（5 步）           │
│  · SIMD 评分内核（NEON / AVX-512BW）     │
│  · IdMapIndex（O(1) 删除）              │
│  · 零 codebook / 零训练                  │
├─────────────────────────────────────────┤
│         Google TurboQuant 算法           │
│  · ICLR 2026, arXiv:2504.19874         │
│  · 匹配 Shannon 失真率下界               │
└─────────────────────────────────────────┘
```

### PostgreSQL 向量搜索三大开源选项

| 扩展 | 核心优势 | 适用场景 |
|------|---------|---------|
| **pgvector** | 生产级验证，功能最全（HNSW L2/IP/L1, halfvec, sparsevec） | 无内存压力，重视成熟度 |
| **pgvectorscale** | SOTA 延迟（StreamingDiskANN），50M+ 行 | 数千万行规模 |
| **pg_turbovec** | **最小磁盘占用**，内核过滤 ANN，零训练 | **内存主导成本方程** |

## 总结

5 条建议：

1. **存储是瓶颈 → 先试 pg_turbovec 4-bit**，1.000 R@10 + 8× 压缩，没有理由不试
2. **延迟是瓶颈 → 留在 pgvector HNSW**，子线性图不是白叫的
3. **过滤搜索频繁 → pg_turbovec allowlist**，SIMD 内核短路，越过滤越快
4. **千万级 RAG → pg_turbovec 2-bit**，62GB → 4GB，单机跑得动
5. **两者共存 → 不用二选一**，独立 schema 和类型，按场景选索引

pg_turbovec 不是一个"更好的 pgvector"，而是一个**用数学换内存**的互补方案。TurboQuant 证明了：不需要看数据，不需要训练 codebook，靠随机旋转 + Lloyd-Max 量化就能逼近 Shannon 极限。

当你内存不够的时候，这个数学能帮你省 20 倍。

### 引用链接

- **pg_turbovec 仓库**：https://codeberg.org/gregburd/pg_turbovec
- **turbovec Rust crate**：https://crates.io/crates/turbovec
- **TurboQuant 论文（ICLR 2026）**：https://arxiv.org/abs/2504.19874
- **pgvector（对比参照）**：https://github.com/pgvector/pgvector
- **pgrx 框架**：https://github.com/pgcentralfoundation/pgrx
