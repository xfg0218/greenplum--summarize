# PostGIS是什么
```
PostGIS 是一个开源程序，它为对象－关系型数据库PostgreSQL提供了存储空间地理数据的支持，使PostgreSQL成为了一个空间数据库，
能够进行空间数据管理、数量测量与几何拓扑分析。PostGIS 实现了开放地理空间协会所提出的基本要素类（点、线、面、多点、多线、多面等）的SQL实现参考。
```

# PostGIS 基础知识
```
4326  GCS_WGS_1984   World Geodetic System (WGS)
26986  美国马萨诸塞州地方坐标系（区域坐标系） 投影坐标, 平面坐标

PostGIS支持所有的空间数据类型
这些类型包括：点（POINT）、线（LINESTRING）、多边形（POLYGON）、多点 （MULTIPOINT）、多线（MULTILINESTRING）、多多边形（MULTIPOLYGON）和集合对象集 （GEOMETRYCOLLECTION）等。

PostGIS支持所有的对象表达方法
比如WKT和WKB。

PostGIS支持所有的数据存取和构造方法
如GeomFromText()、AsBinary()，以及GeometryN()等。

PostGIS提供简单的空间分析函数
如Area和Length
同时也提供其他一些具有复杂分析功能的函数
比如Distance。

PostGIS提供了对于元数据的支持
如GEOMETRY_COLUMNS和SPATIAL_REF_SYS
同时，PostGIS也提供了相应的支持函数
如AddGeometryColumn和DropGeometryColumn。
```

# OGC的WKB和WKT格式
```
OGC定义了两种描述几何对象的格式，分别是WKB（Well-Known Binary）和WKT（Well-Known Text）。

```
几何要素 | WKT格式
-- | --
点 | POINT(0 0)
线 | LINESTRING(0 0,1 1,1 2)
面 | POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1, 2 1, 2 2, 1 2,1 1))
多点 | MULTIPOINT(0 0,1 2)
多线 | MULTILINESTRING((0 0,1 1,1 2),(2 3,3 2,5 4))
多面 | MULTIPOLYGON(((0 0,4 0,4 4,0 4,0 0),(1 1,2 1,2 2,1 2,1 1)), ((-1 -1,-1 -2,-2 -2,-2 -1,-1 -1)))
几何集合 | GEOMETRYCOLLECTION(POINT(2 3),LINESTRING((2 3,3 4)))


# 插入数据实例
```
INSERT INTO table (SHAPE,NAME) VALUES (GeomFromText('POINT(116.39 39.9)', 4326), '北京');
```

# EWKT、EWKB和Canonical格式
```
EWKT和EWKB相比OGC WKT和WKB格式主要的扩展有3DZ、3DM、4D坐标和内嵌空间参考支持。
```

几何类型 | 格式
-- | --
3D点 | POINT(0 0 0)
内嵌空间参考的点 | SRID=32632;POINT(0 0)
带M值的点 | POINTM(0 0 0)
带M值的3D点 | POINT(0 0 0 0)
内嵌空间参考的带M值的多点 | SRID=4326;MULTIPOINTM(0 0 0,1 2 1)


# 插入数据实例
```
INSERT INTO table (SHAPE, NAME) VALUES(GeomFromEWKT('SRID=4326;POINTM(116.39 39.9 10)'), '北京')
```
# SQL-MM格式
```
SQL-MM格式定义了一些插值曲线，这些插值曲线和EWKT有点类似，也支持3DZ、3DM、4D坐标，但是不支持嵌入空间参考。
```
几何类型 | 格式
-- | --
插值圆弧 | CIRCULARSTRING(0 0, 1 1, 1 0)
插值复合曲线 | COMPOUNDCURVE(CIRCULARSTRING(0 0, 1 1, 1 0),(1 0, 0 1))
曲线多边形 | CURVEPOLYGON(CIRCULARSTRING(0 0, 4 0, 4 4, 0 4, 0 0),(1 1, 3 3, 3 1, 1 1))
多曲线 | MULTICURVE((0 0, 5 5),CIRCULARSTRING(4 0, 4 4, 8 4))
多曲面 | MULTISURFACE(CURVEPOLYGON(CIRCULARSTRING(0 0, 4 0, 4 4, 0 4, 0 0),(1 1, 3 3, 3 1, 1 1)),((10 10, 14 12, 11 10, 10 10),(11 11, 11.5 11, 11 11.5, 11 11)))


# 常几何类型和函数
名字 | 存储空间 | 描述 | 表现形式
-- | -- | -- | --
point | 16字节 | 平面上的点 | (x,y)
line | 32字节 | 直线 | {A,B,C}
lseg | 32字节 | 线段 | ((x1,y1),(x2,y2))
box | 32字节 | 矩形 | ((x1,y1),(x2,y2))
path | 16+16n字节 | 闭合路径 | ((x1,y1),…)
path | 16+16n字节 | 开放路径 | [(x1,y1),…]
polygon | 40+16n字节 | 多边形 | ((x1,y1),…)
circle | 24字节 | 圆 | <(x,y),r>

```
--  点
POINT(0 0)

-- 线
LINESTRING(0 0,1 1,1 2)

-- 面
POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1, 2 1, 2 2, 1 2,1 1))

-- 多点
MULTIPOINT((0 0),(1 2))

-- 多线
MULTILINESTRING((0 0,1 1,1 2),(2 3,3 2,5 4))

-- 多面
MULTIPOLYGON(((0 0,4 0,4 4,0 4,0 0),(1 1,2 1,2 2,1 2,1 1)), ((-1 -1,-1 -2,-2 -2,-2 -1,-1 -1))) 

-- 几何集合
GEOMETRYCOLLECTION(POINT(2 3),LINESTRING(2 3,3 4))
```


# 常用操作符
操作符 | 描述 | 示例 | 结果
-- | -- | -- | --
`+` | 平移 | select box '((0,0),(1,1))' + point '(2.0,0)'; | (3,1),(2,0)
`–` | 平移 | select box '((0,0),(1,1))' – point '(2.0,0)'; | (-1,1),(-2,0)
`*` | 伸缩/旋转 | select box '((0,0),(1,1))' * point '(2.0,0)'; | (2,2),(0,0)
`/` | 伸缩/旋转 | select box '((0,0),(2,2))' / point '(2.0,0)'; | (1,1),(0,0)
`#` | 交点或者交面 | select box'((1,-1),(-1,1))' # box'((1,1),(-1,-1))'; | (1,1),(-1,-1)
`#` | path或polygon的顶点数 | select #path'((1,1),(2,2),(2,1))'; | 3
@-@ | 长度或周长 | select @-@ path'((1,1),(2,2),(2,1))'; | 3.414213562
@@ | 中心 | select @@ circle'<(0,0),1>'; | (0,0)
`##` | 第一个操作数和第二个操作数的最近点 | select point '(0,0)' ## lseg '((2,0),(0,2))'; | (1,1)
<-> | 间距 | select circle '<(0,0),1>' <-> circle '<(5,0),1>'; | 3
&& | 是否有重叠 | select box '((0,0),(1,1))' && box '((0,0),(2,2))'; | t
<< | 是否严格在左 | select circle '((0,0),1)' << circle '((5,0),1)'; | t
>> | 是否严格在右 | select circle '((0,0),1)' >> circle '((5,0),1)'; | f
&< | 是否没有延伸到右边 | select box '((0,0),(1,1))' &< box '((0,0),(2,2))'; | t
&> | 是否没有延伸到左边 | select box '((0,0),(3,3))' &> box '((0,0),(2,2))'; | t
<<\| | 是否严格在下 | select box '((0,0),(3,3))' <<\| box '((3,4),(5,5))'; | t
\|>> | 是否严格在上 | select box '((3,4),(5,5))' \|>> box '((0,0),(3,3))'; | t
&<\| | 是否没有延伸到上面 | select box '((0,0),(1,1))' &<\| box '((0,0),(2,2))'; | t
\|&> | 是否没有延伸到下面 | select box '((0,0),(3,3))' \|&> box '((0,0),(2,2))'; | t
<^ | 是否低于（允许接触） | select box '((0,0),(3,3))' <^ box '((3,3),(4,4))'; | t
>^ | 是否高于（允许接触） | select box '((0,0),(3,3))' >^ box '((3,3),(4,4))'; | f
?# | 是否相交 | select lseg '((-1,0),(1,0))' ?# box '((-2,-2),(2,2))'; | t
?- | 是否水平对齐 | select ?- lseg '((-1,1),(1,1))'; | t
?- | 两边图形是否水平对齐 | select point '(1,0)' ?- point '(0,0)'; | t
?\| | 是否竖直对齐 | select ?\| lseg '((-1,0),(1,0))'; | f
?\| | 两边图形是否竖直对齐 | select point '(0,1)' ?\| point '(0,0)'; | t
?-\| | 是否垂直 | select lseg '((0,0),(0,1))' ?-\| lseg '((0,0),(1,0))'; | t
?\|\| | 是否平行 | select lseg '((-1,0),(1,0))' ?\|\| lseg '((-1,2),(1,2))'; | t
@> | 是否包含 | select circle '((0,0),2)' @> point '(1,1)'; | t
<@ | 是否包含于或在图形上 | select point '(1,1)' <@ circle '((0,0),2)'; | t
~= | 是否相同 | select polygon '((0,0),(1,1))' ~= polygon '((1,1),(0,0))'; | t



# 常用函数
函数 | 返回值 | 描述 | 示例 | 结果
-- | -- | -- | -- | --
area(object) | double precision | 面积 | select area(circle'((0,0),1)'); | 3.141592654
center(object) | point | 中心 | select center(box'(0,0),(1,1)'); | (0.5,0.5)
diameter(circle) | double precision | 圆周长 | select diameter(circle '((0,0),2.0)'); | 4
height(box) | double precision | 矩形竖直高度 | select height(box '((0,0),(1,1))'); | 1
isclosed(path) | boolean | 是否为闭合路径 | select isclosed(path '((0,0),(1,1),(2,0))'); | t
isopen(path) | boolean | 是否为开放路径 | select isopen(path '[(0,0),(1,1),(2,0)]'); | t
length(object) | double precision | 长度 | select length(path '((-1,0),(1,0))'); | 4
npoints(path) | int | path中的顶点数 | select npoints(path '[(0,0),(1,1),(2,0)]'); | 3
npoints(polygon) | int | 多边形的顶点数 | select npoints(polygon '((1,1),(0,0))'); | 2
pclose(path) | path | 将开放path转换为闭合path | select pclose(path '[(0,0),(1,1),(2,0)]'); | ((0,0),(1,1),(2,0))
popen(path) | path | 将闭合path转换为开放path | select popen(path '((0,0),(1,1),(2,0))'); | [(0,0),(1,1),(2,0)]
radius(circle) | double precision | 圆半径 | select radius(circle '((0,0),2.0)'); | 2
width(box) | double precision | 矩形的水平长度 | select width(box '((0,0),(1,1))'); | 1

# OGC标准函数
## 管理函数

函数 | 说明
-- | --
AddGeometryColumn(, , , , , ) | 添加几何字段
DropGeometryColumn(, , ) | 删除几何字段
Probe_Geometry_Columns() | 检查数据库几何字段并在geometry_columns中归档
ST_SetSRID(geometry, integer) | 给几何对象设置空间参考（在通过一个范围做空间查询时常用）


## 几何对象关系函数
函数 | 说明
-- | --
ST_Distance(geometry, geometry) | 获取两个几何对象间的距离
ST_DWithin(geometry, geometry, float) | 如果两个几何对象间距离在给定值范围内，则返回TRUE
ST_Equals(geometry, geometry) | 判断两个几何对象是否相等（比如LINESTRING(0 0, 2 2)和LINESTRING(0 0, 1 1, 2 2)是相同的几何对象）
ST_Disjoint(geometry, geometry) | 判断两个几何对象是否分离
ST_Intersects(geometry, geometry) | 判断两个几何对象是否相交
ST_Touches(geometry, geometry) | 判断两个几何对象的边缘是否接触
ST_Crosses(geometry, geometry) | 判断两个几何对象是否互相穿过
ST_Within(geometry A, geometry B) | 判断A是否被B包含
ST_Overlaps(geometry, geometry) | 判断两个几何对象是否是重叠
ST_Contains(geometry A, geometry B) | 判断A是否包含B
ST_Covers(geometry A, geometry B) | 判断A是否覆盖 B
ST_CoveredBy(geometry A, geometry B) | 判断A是否被B所覆盖
ST_Relate(geometry, geometry, intersectionPatternMatrix) | 通过DE-9IM 矩阵判断两个几何对象的关系是否成立
ST_Relate(geometry, geometry) | 获得两个几何对象的关系（DE-9IM矩阵）


## 几何对象处理函数
函数 | 说明
-- | --
ST_Centroid(geometry) | 获取几何对象的中心
ST_Area(geometry) | 面积量测
ST_Length(geometry) | 长度量测
ST_PointOnSurface(geometry) | 返回曲面上的一个点
ST_Boundary(geometry) | 获取边界
ST_Buffer(geometry, double, [integer]) | 获取缓冲后的几何对象
ST_ConvexHull(geometry) | 获取多几何对象的外接对象
ST_Intersection(geometry, geometry) | 获取两个几何对象相交的部分
ST_Shift_Longitude(geometry) | 将经度小于0的值加360使所有经度值在0-360间
ST_SymDifference(geometry A, geometry B) | 获取两个几何对象不相交的部分（A、B可互换）
ST_Difference(geometry A, geometry B) | 从A去除和B相交的部分后返回
ST_Union(geometry, geometry) | 返回两个几何对象的合并结果
ST_Union(geometry set) | 返回一系列几何对象的合并结果
ST_MemUnion(geometry set) | 用较少的内存和较长的时间完成合并操作，结果和ST_Union


## 几何对象存取函数
函数 | 说明
-- | --
ST_AsText(geometry) | 获取几何对象的WKT描述
ST_AsBinary(geometry) | 获取几何对象的WKB描述
ST_SRID(geometry) | 获取几何对象的空间参考ID
ST_Dimension(geometry) | 获取几何对象的维数
ST_Envelope(geometry) | 获取几何对象的边界范围
ST_IsEmpty(geometry) | 判断几何对象是否为空
ST_IsSimple(geometry) | 判断几何对象是否不包含特殊点（比如自相交）
ST_IsClosed(geometry) | 判断几何对象是否闭合
ST_IsRing(geometry) | 判断曲线是否闭合并且不包含特殊点
ST_NumGeometries(geometry) | 获取多几何对象中的对象个数
ST_GeometryN(geometry,int) | 获取多几何对象中第N个对象
ST_NumPoints(geometry) | 获取几何对象中的点个数
ST_PointN(geometry,integer) | 获取几何对象的第N个点
ST_ExteriorRing(geometry) | 获取多边形的外边缘
ST_NumInteriorRings(geometry) | 获取多边形内边界个数
ST_NumInteriorRing(geometry) | (同上)
ST_InteriorRingN(geometry,integer) | 获取多边形的第N个内边界
ST_EndPoint(geometry) | 获取线的终点
ST_StartPoint(geometry) | 获取线的起始点
ST_GeometryType(geometry) | 获取几何对象的类型
ST_GeometryType(geometry) | 类似上，但是不检查M值，即POINTM对象会被判断为point
ST_X(geometry) | 获取点的X坐标
ST_Y(geometry) | 获取点的Y坐标
ST_Z(geometry) | 获取点的Z坐标
ST_M(geometry) | 获取点的M值

## 类型转换函数
函数 | 返回类型 | 描述 | 示例 | 结果
-- | -- | -- | -- | --
box(circle) | box | 圆形转矩形 | select box(circle ‘((0,0),2.0)’); | (1.41421356237309,1.41421356237309),(-1.41421356237309,-1.41421356237309)
box(point) | box | 点转空矩形 | select box(point ‘(0,0)’); | (0,0),(0,0)
box(point, point) | box | 点转矩形 | select box(point ‘(0,0)’, point ‘(1,1)’); | (1,1),(0,0)
box(polygon) | box | 多边形转矩形 | select box(polygon ‘((0,0),(1,1),(2,0))’); | (2,1),(0,0)
bound_box(box, box) | box | 将两个矩形转换成一个边界矩形 | select bound_box(box ‘((0,0),(1,1))’, box ‘((3,3),(4,4))’); | (4,4),(0,0)
circle(box) | circle | 矩形转圆形 | select circle(box ‘((0,0),(1,1))’); | <(0.5,0.5),0.707106781186548>
circle(point, double precision) | circle | 圆心与半径转圆形 | select circle(point ‘(0,0)’, 2.0); | <(0,0),2>
circle(polygon) | circle | 多边形转圆形 | select circle(polygon ‘((0,0),(1,1),(2,0))’); | <(1,0.333333333333333),0.924950591148529>
line(point, point) | line | 点转直线 | select line(point ‘(-1,0)’, point ‘(1,0)’); | {0,-1,0}
lseg(box) | lseg | 矩形转线段 | select lseg(box ‘((-1,0),(1,0))’); | [(1,0),(-1,0)]
lseg(point, point) | lseg | 点转线段 | select lseg(point ‘(-1,0)’, point ‘(1,0)’); | [(-1,0),(1,0)]
path(polygon) | path | 多边形转path | select path(polygon ‘((0,0),(1,1),(2,0))’); | ((0,0),(1,1),(2,0))
point(double precision, double precision) | point | 点 | select point(23.4, -44.5); | (23.4,-44.5)
point(box) | point | 矩形转点 | select point(box ‘((-1,0),(1,0))’); | (0,0)
point(circle) | point | 圆心 | select point(circle ‘((0,0),2.0)’); | (0,0)
point(lseg) | point | 线段中心 | select point(lseg ‘((-1,0),(1,0))’); | (0,0)
point(polygon) | point | 多边形的中心 | select point(polygon ‘((0,0),(1,1),(2,0))’); | (1,0.333333333333333)
polygon(box) | polygon | 矩形转4点多边形 | select polygon(box ‘((0,0),(1,1))’); | ((0,0),(0,1),(1,1),(1,0))
polygon(circle) | polygon | 圆形转12点多边形 | select polygon(circle ‘((0,0),2.0)’); | ((-2,0),(-1.73205080756888,1),(-1,1.73205080756888),(-1.22460635382238e-16,2),(1,1.73205080756888),(1.73205080756888,1),(2,2.4492127
0764475e-16),(1.73205080756888,-0.999999999999999),(1,-1.73205080756888),(3.67381906146713e-16,-2),(-0.999999999999999,-1.73205080756
888),(-1.73205080756888,-1))
polygon(npts, circle) | polygon | 圆形转npts点多边形 | select polygon(12, circle ‘((0,0),2.0)’); | ((-2,0),(-1.73205080756888,1),(-1,1.73205080756888),(-1.22460635382238e-16,2),(1,1.73205080756888),(1.73205080756888,1),(2,2.4492127
0764475e-16),(1.73205080756888,-0.999999999999999),(1,-1.73205080756888),(3.67381906146713e-16,-2),(-0.999999999999999,-1.73205080756
888),(-1.73205080756888,-1))
polygon(path) | polygon | 将path转多边形 | select polygon(path ‘((0,0),(1,1),(2,0))’); | ((0,0),(1,1),(2,0))


# PostGIS 系统表查看
## spatial_ref_sys表
```
在基于PostGIS模板创建的数据库的public模式下，有一个spatial_ref_sys表，它存放的是OGC规范的空间参考。
```

## geometry_columns表
```
1、geometry_columns表存放了当前数据库中所有几何字段的信息，比如我当前的库里面有两个空间表，在geometry_columns表中就可以找到这两个空间表中几何字段的定义
2、其中f_table_schema字段表示的是空间表所在的模式，f_table_name字段表示的是空间表的表名，f_geometry_column字段表示的是该空间表中几何字段的名称，srid字段表示的是该空间表的空间参考。

taix=# select * from geometry_columns;
 f_table_catalog | f_table_schema | f_table_name  | f_geometry_column | coord_dimension | srid | type
-----------------+----------------+---------------+-------------------+-----------------+------+-------
 taix            | public         | trip          | pickup_geom       |               2 | 2163 | POINT
 taix            | public         | trip          | dropoff_geom      |               2 | 2163 | POINT
 taix            | public         | trip_1_prt_1  | pickup_geom       |               2 | 2163 | POINT
 taix            | public         | trip_1_prt_1  | dropoff_geom      |               2 | 2163 | POINT

```





