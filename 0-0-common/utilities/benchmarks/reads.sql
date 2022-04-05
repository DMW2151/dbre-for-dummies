/*
This will (should) force an index scan (but maybe not, planner might try to seq scan...)
*/
SELECT id, r_hash FROM kv_random kr WHERE id > gen_random_uuid() limit 1;