# 生成随机数

## 生成0-10以内的数据
```
postgres=# SELECT floor(random() * 11) AS random_number
FROM generate_series(1, 10);
 random_number
---------------
             2
            10
             9
             0
             5
             1
             2
             0
             8
             2
(10 rows)
```

## 生成0-100以内的数据
```
postgres=# SELECT floor(random() * 101) AS random_number
FROM generate_series(1, 10);
 random_number
---------------
            10
            21
            23
             0
            12
            53
            72
            78
            87
            17
(10 rows)
```


## 生成从2020年1月1日到2022年12月31日之间的随机日期
```
SELECT
  (date_trunc('day', '2020-01-01'::date) + random() * (date_trunc('day', '2022-12-31'::date) - date_trunc('day', '2020-01-01'::date)))::date AS random_date
FROM generate_series(1, 10);
 random_date
-------------
 2021-05-10
 2022-09-13
 2021-03-25
 2022-08-10
 2021-01-02
 2022-06-12
 2021-10-23
 2020-11-30
 2020-03-04
 2021-08-20
(10 rows)
```

## 随机生成本月的日期
```

postgres=# SELECT current_date - floor((random() * 25))::int;
  ?column?
------------
 2023-05-28
(1 row)

postgres=# SELECT current_date - floor((random() * 25))::int;
  ?column?
------------
 2023-05-24
(1 row)
```



## 生成一天之内的随机时间
```
postgres=# SELECT
  make_time(
    floor(random() * 24)::int,
    floor(random() * 60)::int,
    floor(random() * 60)::int
  ) AS random_time
FROM generate_series(1, 10);
 random_time
-------------
 10:50:12
 13:36:46
 04:16:54
 13:34:32
 23:22:21
 09:22:45
 08:16:41
 08:14:21
 20:57:43
 20:12:59
(10 rows)
```

## 生成本月日期
```
postgres=# SELECT concat(current_date - floor((random() * 25))::int,' ',make_time(floor((random() * 12))::int, floor((random() * 60))::int, floor((random() * 60))::int));
       concat
---------------------
 2023-05-19 00:55:41
(1 row)
```










