#! /bin/bash 
set -e -x

# Add PostgreSQL to Apt Repo
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' &&\
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update Apt and Install PostgreSQL
sudo apt-get -y update &&\
sudo apt-get -y upgrade &&\
sudo apt install -y \
    postgresql \
    postgresql-contrib &&\
sudo apt-get clean
