#! /bin/bash

# Upgrade Apt && Install fio
apt-get -y update &&\
    apt-get -y upgrade &&\
    apt-get -y install fio

# Recommended by AWS -  Idle cores in a supported CPU can enter a C-state to save power
# This latency can interfere with processor benchmarking routines.
for i in `seq 1 $((N-1))`;
    do cpupower idle-set -d $i;
done
