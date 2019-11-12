# user-drop
	主要介绍在Greenplum数据库中删除已经赋权的用户，涉及到database，schema，table，function权限的撤销操作


# 1、撤销用户在数据库上的权限
	-- 移除数据库的权限
	revoke  all  on  database  databasename   from  username;
	
	databasename ：数据库的名字
	username  : 角色的名字
	
# 2、撤销用户在schema上的权限
	-- 移除schema的权限
	revoke all on schema schema1,schema2 from username;
	
	schema1,schema2 : schema的集合，以逗号分开
	username  : 角色的名字
	
# 3、撤销用户在table上的权限
	select 'revoke all on '||table_schema||'.'||table_name||' from username cascade; ' from 
	information_schema.table_privileges 
	where grantee='username';
	
	username  : 角色的名字
	
	用此语句查询出revoke的语句，去执行即可

# 4、撤销用户在function上的权限
	-- 查询该用户的所属的函数
	select * from information_schema.routine_privileges where grantee='username';
	
	-- 移除权限
	revoke all  on function schemaname.functionname from username;
	
	username  : 角色的名字
	使用第一个语句把该角色关于函数的语句查询出来，使用第二个语句撤销语句即可

# 5、删除角色
	drop role if exists username;
	
	username  : 角色的名字