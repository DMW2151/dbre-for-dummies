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
echo "host      postgres          postgres        ${vpc_cidr_block}       trust" >>  /etc/postgresql/14/main/pg_hba.conf
echo "host      replication       replicator      ${vpc_cidr_block}       trust" >>  /etc/postgresql/14/main/pg_hba.conf

sudo -u postgres createuser -U postgres replicator -c 5 --replication

# Reloading PostgreSQL also reloads the config and finishes intializing the instance...
sudo systemctl stop postgresql &&\
sudo systemctl start postgresql