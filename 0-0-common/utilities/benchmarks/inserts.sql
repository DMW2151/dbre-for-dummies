
/* 
Insert a Single Random Row into kv_random

This is terrible and you should batch inserts instead of running single
streaming inserts against a DB, but OK...
*/

INSERT INTO kv_random VALUES (
    gen_random_uuid(), md5(random()::text)
); 