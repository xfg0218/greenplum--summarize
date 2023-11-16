# pgcrypto 安装
```
-- 创建插件
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

# 创建加密`function`
```
create or replace function encrypt_text(input_text text, secret_key text) returns text as $$
declare
   encrypted_text text;
begin
   select encode(encrypt(input_text::bytea, secret_key::bytea, 'aes'::text), 'hex') into encrypted_text;
   return encrypted_text;
end;
$$ language plpgsql;
```

# 创建解密`function`
```
create or replace function decrypt_text(encrypted_text text, secret_key text) returns text as $$
declare
   decrypted_text text;
begin
  select convert_from(decrypt(decode(encrypted_text, 'hex')::bytea, secret_key::bytea, 'aes'::text), 'utf8') into decrypted_text;
   return decrypted_text;
end;
$$ language plpgsql;
```

# 测试加解密
```
-- 测试加密
select encrypt_text('greenplum-test','00B9AB0B828FF68872F21A837FC303668428DEA11DCD1B24429D0C99E24EED83D5');

-- 测试解密
select decrypt_text('eb111eb6bf526f7da45c8e2ec0f86d72','00B9AB0B828FF68872F21A837FC303668428DEA11DCD1B24429D0C99E24EED83D5');
```

# 参考资料
```
-- PG
https://www.postgresql.org/docs/12/pgcrypto.html

-- pgcrypto加密插件
https://developer.aliyun.com/article/58377

-- 数据加密之 pgcrypto
https://tonydong.blog.csdn.net/article/details/109073000?ydreferer=aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3NpbGVuY2VyYXkvYXJ0aWNsZS9kZXRhaWxzLzExMDQ4MTIyNQ%3D%3D?ydreferer=aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3NpbGVuY2VyYXkvYXJ0aWNsZS9kZXRhaWxzLzExMDQ4MTIyNQ%3D%3D


```



