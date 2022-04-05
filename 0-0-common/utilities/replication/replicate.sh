#! /bin/sh

# See: https://www.digitalocean.com/community/tutorials/how-to-set-up-physical-streaming-replication-with-postgresql-12-on-ubuntu-20-04

sudo -u postgres pg_basebackup \
    -Fp -Xs -R \
    -h primary-ip-addr \
    -p 5432 -U test \
    -D /var/lib/postgresql/12/main/
