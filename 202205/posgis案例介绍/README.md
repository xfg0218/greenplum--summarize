# PostGIS 使用案例
```
查经纬度的坐标点的地图API
https://lbsyun.baidu.com/jsdemo/demo/yLngLatLocation.htm


POINT(114.025919 22.534866)
114.025919: 表时经度
22.534866：表时维度


中国国家基础地理信息数据下载
http://gaohr.win/site/blogs/2017/2017-04-18-GIS-basic-data-of-China.html#County_pl


```

# 计算两点之间的距离
```
两个点之间的距离,距离单位是m

距离计算函数
ST_Distance

文本转换地理几何类型函数
ST_GeogFromText 。

文本转换为地理几何类型函数
ST_GeographyFromText

-- 921.376291501 单位 m
select ST_Distance(ST_GeographyFromText('SRID=4326;POINT(114.017299 22.537126)'),
ST_GeographyFromText('SRID=4326;POINT(114.025919 22.534866)'));

--  921.376291501 单位 m
SELECT ST_Distance(ST_GeomFromText('POINT(114.017299 22.537126)',4326):: geography,
ST_GeomFromText('POINT(114.025919 22.534866)', 4326):: geography);

-- 920.285190004 单位是m
SELECT ST_DistanceSphere(ST_GeomFromText('POINT(114.017299 22.537126)',4326),
ST_GeomFromText('POINT(114.025919 22.534866)', 4326));

-- 0.008911341088754828 两点之间的斜度数
SELECT ST_Distance(ST_GeomFromText('POINT(114.017299 22.537126)',4326),
ST_GeomFromText('POINT(114.025919 22.534866)', 4326));

```

# 范围内的点查找
```
-- 查看两点的距离是否有1000m，单位米m
-- 返回t是在范围内，否则不再
SELECT ST_DWithin(
ST_GeographyFromText('SRID=4326;POINT(114.017299 22.537126)'),
ST_GeographyFromText('SRID=4326;POINT(114.025919 22.534866)'),1000);

-- 查看两点直接的斜度，是否在制定的斜度内
-- 返回t是在范围内，f不在斜度内
SELECT ST_DWithin(ST_GeomFromText('POINT(114.017299 22.537126)',4326),
ST_GeomFromText('POINT(114.025919 22.534866)', 4326),0.00811134108875483);


-- 查找给定经纬度5km以内的点
-- geom_point::geography，单位变成米, 否则默认距离单位是度。

SELECT
    uuid,
    longitude,
    latitude,
    ST_DistanceSphere (
        geom_point,
    ST_GeomFromText ( 'POINT(121.248642 31.380415)', 4326 )) distance 
FROM
    s_poi_gaode 
WHERE
    ST_DWithin ( geom_point :: geography, ST_GeomFromText ( 'POINT(121.248642 31.380415)', 4326 ) :: geography, 5000 ) IS TRUE 
    order by distance desc
    LIMIT 30;

-- 查看给定坐标的最近的10个点
SELECT * FROM s_poi_gaode_gps ORDER BY geom_point <-> ST_GeomFromText ( 'POINT(121.248642 31.380415)', 4326 )  LIMIT 10;

```

# 弯曲的几何实体案例
```
-- 创建表
create table global_points (
id int,
name varchar(64),
location geography(point,4326)
) Distributed by(id);

-- 插入数据
insert into global_points (id,name, location) values (1,'town', 'srid=4326;point(-110 30)');
insert into global_points (id,name, location) values (2,'forest', 'srid=4326;point(-109 29)');
insert into global_points (id,name, location) values (3,'london', 'srid=4326;point(0 49)');

-- 创建索引
create index global_points_gix on global_points using gist ( location );

-- 查看数据
postgis=# select * from global_points;
 id |  name  |                      location
----+--------+----------------------------------------------------
  2 | forest | 0101000020E61000000000000000405BC00000000000003D40
  3 | london | 0101000020E610000000000000000000000000000000804840
  1 | town   | 0101000020E61000000000000000805BC00000000000003E40
(3 rows)

-- 查询给位置1000公里之内的城镇
select name from global_points where st_dwithin(location, 'srid=4326;point(-110 29)'::
geography, 1000000);

-- 计算从西雅图(-122.33 47.606)飞往伦敦(0.0 51.5)的距离
select st_distance('linestring(-122.33 47.606, 0.0 51.5)'::geography, 'point(-21.96
64.15)'::geography);

-- 计算点线之间的距离
select st_distance('linestring(-122.33 47.606, 0.0 51.5)'::geometry, 'point(-21.96 64.15)
'::geometry);

```

# 点在集合体内的案例
```
-- 生成基础图层数据
shp2pgsql -s 4326 $PATH/country.shp  public.table_shapefile > load.sql

-- 加载数据到数据库
psql  -d database -f load.sql

-- 查看矢量图的数量
postgres =# select count(*) from table_shapefile;
 count
-------
  3366
(1 row)

-- 查看点在制定的集合内（北京市通州区）
SELECT count(*) FROM tablename WHERE
(ST_intersects((select geom  from table_shapefile where adcode99= '110112'),tablename.point));

-- 以下是把最新的经纬度生成一个点的信息,持续进行更新。
last(ST_SetSRID(ST_MakePoint(lng, lat), 4326),time) as point

-- 查看已知的集合图形内的点
SELECT count(*) FROM tablename WHERE (ST_intersects(geometry('SRID=4326;Polygon((-31.8193460000999980 50.8630180000999990,23.4445540000999980 50.8630180000999990,23.4445540000999980 -0.0000000001000000,-31.8193460000999980 -0.0000000001000000,-31.8193460000999980 50.8630180000999990))'),tablename.point));


```



