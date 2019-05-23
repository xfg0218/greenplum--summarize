SELECT ns.nspname,pc.relname FROM pg_class pc,pg_namespace ns WHERE pc.relnamespace = ns.oid AND relstorage IN ('c', 'a') AND ns.nspname = 'ods';
