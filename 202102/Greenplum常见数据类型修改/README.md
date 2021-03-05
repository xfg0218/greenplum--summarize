# 修改date的格式,需要先把字段转化为text类型再转化为date类型
alter table tablenam alter column "candate" type date using ("candate"::text::date);
 
# 修改表的character字段类型的长度
alter table tablename  alter column filedname type character varying(40);

# 表字段的增加与删除
alter table tablename add id_new varchar(120);
alter table tablename drop column id_new;

# timestamp字段的修改
alter table tablename alter column s_ext_timestamp type timestamp(6) using s_ext_timestamp::timestamp;
 
# numeric字段的修改
alter table tablename alter column regcap type numeric(26,6)  using regcap::numeric;