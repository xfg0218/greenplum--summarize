# 创建用户并修改密码
	创建用户
	create role username  with login password '123456';
	
	修改用户密码
	alter role username with password '123456';
	
	username：用户的名字
	

# 给用户schema的权限
	create schema schemaname;
	
	GRANT all ON schema  schemaname  TO username;
	grant all on schema schemaname to username;
	grant all on schema schemaname to username;
	
	username：用户的名字
	schemaname：schema 的名字
	
	
	
#  表与函数的权限
	grant select  on  tablename to username;
	
	grant all  on function functionName to username;
	
	alter function functionName：function的名字 owner to username;
	
	tablename：表的名字
	username：用户的名字
	functionName：function的名字
	
	
	
	
	
# 查询用户拥有的表的权限
	select * from information_schema.table_privileges where grantee='username' and table_schema='schemaname' and table_name='tablename';
	
	select DISTINCT * from (
	select col.table_schema||'.'||col.table_name as tablename from information_schema.columns col where
	col.table_schema='schemaname' and col.table_name like 'tablename'  
	order by col.ordinal_position ) astablename;

	
    tablename：表的名字
	username：用户的名字
	schemaname：schema 的名字
	

# 创建授权表的语句
	create or replace function grant_on_all_tables(schema text, usr text)
	returns setof text as $$
	declare
	r record ;
	grantstmt text;
	begin
	for r in select * from pg_class c, pg_namespace nsp
	where c.relnamespace = nsp.oid AND c.relkind='r' AND nspname = schema
	loop
	grantstmt = 'GRANT SELECT ON "'|| quote_ident(schema) || '"."'
	||
	quote_ident(r.relname) || '" to "' || quote_ident(usr) || '"';
	EXECUTE grantstmt;
	return next grantstmt;
	end loop;
	end;
	$$ language plpgsql;
	
	
	GRANT SELECT ON:授权的类型
	
	
# 授权给用户表的权限
	select grant_on_all_tables('schemaname','username');
	
	drop FUNCTION grant_on_all_tables(schema text, usr text);

    
	username：用户的名字
	schemaname：schema 的名字
	
	
	
	
	
	
	
	
