
# Applied Benchmarking Notes

```bash
# Init Benchmarking Statistics on DB
pgbench -i -h localhost -d postgres -U worker

# Create a sample table w. 10M rows of random Key -> Values
psql -h localhost -d postgres -U worker \
    -f /home/ubuntu/benchmark_utils/init_tbl.sql
```

```bash
# Run a read && write benchmark job using:
#
#   - All processes available, on r6gd.xlarge `nproc` == 4
#   - 16 Clients @ 100K Transactions Per Client (Write)
#   - 64 Clients @ 10K Transactions Per Client (Read)
#   - A *very* silly single row read query for each transaction (see `reads.sql`)
#   - A *very* silly single row insert for each transaction (see `inserts.sql`)

pgbench -h localhost -d postgres -U worker \
    -j `(nproc)` -t 10000 -c 64 -f /home/ubuntu/benchmark_utils/reads.sql

# Remember to TRUNCATE (or Wholly Recreate the table) between runs!
pgbench -h localhost -d postgres -U worker \
    -j `(nproc)` -t 100000 -c 16 -f /home/ubuntu/benchmark_utils/inserts.sql
```

```bash
mkdir -p /instance &&\
    mkfs -t xfs /dev/nvme1n1 &&\
    mount /dev/nvme1n1 /instance &&\
    rsync -av /var/lib/postgresql /instance

# Set New Data Directory...
sed -i "s|^data_directory.*|data_directory='/instance/postgresql/14/main'|g" /etc/postgresql/14/main/postgresql.conf

# To Reverse the above; and place the DB back on the root Volume...
sed -i "s|^data_directory.*|data_directory='/var/lib/postgresql/14/main'|g" /etc/postgresql/14/main/postgresql.conf

sudo systemctl stop postgresql &&\
sudo systemctl start postgresql
```
