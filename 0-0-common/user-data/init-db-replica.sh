#! /bin/bash

# Copy the Empty PostgreSQL data Directory to Instance Storage
mkdir -p /instance &&\
    mkfs -t xfs /dev/nvme1n1 &&\
    mount /dev/nvme1n1 /instance &&\
    rsync -av /var/lib/postgresql /instance

# Set New Data Directory... 
# New Listen Rules - Listen on All Addresses in the VPC
sed -i "s|^data_directory.*|data_directory='/instance/postgresql/14/main'|g" /etc/postgresql/14/main/postgresql.conf
sed -i "s|^#listen_addresses.*|listen_addresses = '*'|g" /etc/postgresql/14/main/postgresql.conf

# New HBA Rules - Allow Connection from postgres anywhere in the VPC
echo "host      postgres        postgres        ${vpc_cidr_block}       trust" >>  /etc/postgresql/14/main/pg_hba.conf

# Reloading PostgreSQL also reloads the config and finishes intializing the instance...
sudo systemctl stop postgresql

# Clear the system && backup from the primary db
sudo -u postgres rm -rf /instance/postgresql/14/main/*

# See: https://www.digitalocean.com/community/tutorials/how-to-set-up-physical-streaming-replication-with-postgresql-12-on-ubuntu-20-04
sudo -u postgres pg_basebackup \
    -h "${primary_node_hostname}" \
    -p 5432 \
    -U replicator \
    -D /instance/postgresql/14/main/ \
    -Fp -Xs -R

sudo systemctl start postgresql
