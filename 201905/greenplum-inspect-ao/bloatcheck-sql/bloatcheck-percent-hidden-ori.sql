select  percent_hidden from gp_toolkit.__gp_aovisimap_compaction_info('tablename'::regclass) ORDER BY percent_hidden desc limit 1;
