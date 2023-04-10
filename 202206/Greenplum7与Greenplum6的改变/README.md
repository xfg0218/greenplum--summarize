# Greenplum 7 新增的系统表
| 系统表名 | 描述 |
|:----:|:----:|
| pg_parted_rel|存储正在分区或将要分区的表的信息。|
| pg_shseclabel|存储扩展安全标签信息。|
| pg_stat_subscription|存储订阅者的统计信息。|
| pg_constraint_oid_index|存储约束OID的索引。|
| pg_event_trigger|存储事件触发器信息。|
| pg_partition_rule|存储分区规则的信息。|
| pg_sequence|存储序列信息。|
| pg_subscription|存储订阅者信息。|
| pg_subscription_rel|存储订阅表的信息。|
| pg_trigger|存储触发器信息。|
| pg_trigger_oid_index|存储触发器OID的索引。|
| pg_user_mapping|存储用户映射信息。|
| pg_view_def|存储视图定义的信息。|
| pg_enum|存储枚举类型的信息。|
| pg_enum_oid_index|存储枚举类型OID的索引。|
| pg_enum_typid_label_index|存储枚举类型标签的索引。|
| pg_range|存储范围类型的信息。|
| pg_range_oid_index|存储范围类型OID的索引。|
| pg_range_subtype_index|存储范围类型子类型的索引。|
| pg_policy|存储策略信息。|
| pg_transform|存储转换器信息。|
| pg_transform_oid_index|存储转换器OID的索引。|
| pg_transform_type_name_nsp_index|存储转换器类型名称和命名空间OID的索引。|
| pg_opfamily|存储运算符族的信息。|
| pg_opfamily_oid_index|存储运算符族OID的索引。|
| pg_opfamily_opc_strat_index|存储运算符族策略的索引。|
| pg_opclass|存储运算符类的信息。|
| pg_opclass_oid_index|存储运算符类OID的索引。|
| pg_am|存储访问方法的信息。|
| pg_am_oid_index|存储访问方法OID的索引。|
| pg_attribute_encoding|存储列的编码信息。|
| pg_class_tblspc_relfilenode_index|存储表OID、表空间OID和文件节点号的索引。|
| pg_depend_reference_index|存储引用类型的依赖关系的引用OID的索引。|


# Greenplum 7 和 Greenplum 6 系统表的更详细改动列表
| 系统表 | Greenplum 6 名称 | Greenplum 7 名称 | 改动描述 |
|:----:|:----:|:----:|:----:|
| pg_attribute|pg_attribute|pg_attribute|系统表结构不变|
| pg_authid|pg_shadow|pg_authid|表名和结构不变，更名为 pg_authid。|
| pg_auth_members|pg_auth_members|pg_auth_members|系统表结构不变。|
| pg_class|pg_class|pg_class|系统表结构不变。|
| pg_constraint|pg_constraint|pg_constraint|系统表结构不变。|
| pg_conversion|pg_conversion|pg_conversion|系统表结构不变。|
| pg_depend|pg_depend|pg_depend|系统表结构不变。|
| pg_description|pg_description|pg_description|系统表结构不变。|
| pg_enum|pg_enum|pg_enum|系统表结构不变。|
| pg_event_trigger|pg_event_trigger|pg_event_trigger|系统表结构不变。|
| pg_extension|pg_extension|pg_extension|系统表结构不变。|
| pg_foreign_data_wrapper|pg_foreign_data_wrapper|pg_foreign_data_wrapper|系统表结构不变。|
| pg_foreign_server|pg_foreign_server|pg_foreign_server|系统表结构不变。|
| pg_foreign_table|pg_foreign_table|pg_foreign_table|系统表结构不变。|
| pg_index|pg_index|pg_index|系统表结构不变。|
| pg_inherits|pg_inherits|pg_inherits|系统表结构不变。|
| pg_language|pg_language|pg_language|系统表结构不变。|
| pg_largeobject|pg_largeobject|pg_largeobject|系统表结构不变。|
| pg_namespace|pg_namespace|pg_namespace|系统表结构不变。|
| pg_opclass|pg_opclass|pg_opclass|系统表结构不变。|
| pg_operator|pg_operator|pg_operator|系统表结构不变。|
| pg_partition|无|pg_partition|新增的系统表，用于存储分区表的元数据信息。|


#  Greenplum 7和Greenplum 6中部分系统表的改变
| 系统表 | 改变 |
|:----:|:----:|
| pg_class|新增 columnattid 列 |
| pg_namespace|新增 nspinline 列 |
| pg_partition|删除 parchildrelid 列 |
| pg_partition_rule|删除 parchildrelid, paroid 列  |
| pg_attrdef|新增 adbin, adsrc 列 |
| pg_constraint|新增 convalidated 列 |
| pg_inherits|删除 inhrelid 列 |
| pg_type|新增 typcategory 列 |
| gp_distribution_policy|删除 ALTER DISTRIBUTION KEY 语法 |
| gp_distribution_policy_entry|新增 numsegments 列 |
| gp_segment_configuration|新增 data_directory 列 |
| gp_toolkit.gp_size_of_table|新增 compressed_size_in_mb, uncompresesed_size_in_mb 列  |


