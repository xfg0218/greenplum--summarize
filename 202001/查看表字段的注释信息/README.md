# 查看表字段的comment信息,如果字段没有comment则显示空
	SELECT 'tablename' as table_name
		,a.attname                            AS column_name
		,format_type(a.atttypid, a.atttypmod) AS data_type
		,d.description                        AS description
		,a.attnum
		,a.attnotnull                         AS notnull
		,coalesce(p.indisprimary, FALSE)      AS primary_key
		,f.adsrc                              AS default_val
	FROM   pg_attribute    a
	LEFT   JOIN pg_index   p ON p.indrelid = a.attrelid AND a.attnum = ANY(p.indkey)
	LEFT   JOIN pg_description d ON d.objoid  = a.attrelid AND d.objsubid = a.attnum
	LEFT   JOIN pg_attrdef f ON f.adrelid = a.attrelid  AND f.adnum = a.attnum
	WHERE  a.attnum > 0
	AND    NOT a.attisdropped
	AND    a.attrelid = 'tablename'::regclass
	ORDER  BY a.attnum;


	tablename : 表的名字

# 展示效果如下
|table_name|column_name|data_type|description|attnum|notnull|primary_key|default_val|
|---|---|---|---|---|---|---|---
log_history.table_mapping|record_id|character varying(50)|表的唯一键|1|f|f|
log_history.table_mapping|create_table|character varying(2000)|创建的新表|2|f|f|
log_history.table_mapping|create_user|character varying(50)|新表的创建者|3|f|f|


