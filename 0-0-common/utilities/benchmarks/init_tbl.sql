CREATE TABLE IF NOT EXISTS kv_random (
    id UUID PRIMARY KEY,
    r_hash TEXT
);

INSERT INTO kv_random
SELECT
    gen_random_uuid(),
    md5(random()::text)
FROM generate_series(1, 10000000);

REINDEX TABLE kv_random;