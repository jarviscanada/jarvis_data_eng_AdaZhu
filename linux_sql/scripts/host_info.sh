#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
    echo "Usage: bash host_info.sh psql_host psql_port db_name psql_user psql_password"
    exit 1
fi

lscpu_out=$(lscpu)
hostname=$(hostname -f)

cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)

cpu_architecture=$(echo "$lscpu_out" | grep "Architecture" | awk '{print $2}' | xargs)

cpu_model=$(echo "$lscpu_out" | grep "Model name" | cut -d: -f2 | xargs)

cpu_mhz=$(echo "$cpu_model" | awk -F '@' '{print $2}' | awk -F 'G' '{print $1 * 1000}' | xargs)

l2_cache=$(echo "$lscpu_out" | grep "L2 cache" | awk '{print $3}' | sed 's/[a-zA-Z]//g' | xargs)

total_mem=$(grep "MemTotal" /proc/meminfo | awk '{print $2}' | xargs)

timestamp=$(date -u "+%Y-%m-%d %H:%M:%S")

insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, \"timestamp\", total_mem) \
VALUES('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

unset PGPASSWORD
