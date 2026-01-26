#!/bin/bash

# --- Command Line Arguments ---
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check if all 5 parameters are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: bash host_usage.sh psql_host psql_port db_name psql_user psql_password"
    exit 1
fi

# --- 1. Parse Server Usage Data ---
# Pre-fetch vmstat data to avoid multiple calls
vmstat_mb=$(vmstat --unit M)
vmstat_d=$(vmstat -d)
hostname=$(hostname -f)

# Extract metrics using awk and xargs (to trim whitespace)
memory_free=$(echo "$vmstat_mb" | tail -n1 | awk '{print $4}' | xargs)
cpu_idle=$(echo "$vmstat_mb" | tail -n1 | awk '{print $15}' | xargs)
cpu_kernel=$(echo "$vmstat_mb" | tail -n1 | awk '{print $14}' | xargs)
disk_io=$(echo "$vmstat_d" | tail -n1 | awk '{print $10}' | xargs)
disk_available=$(df -BM / | tail -n1 | awk '{print $4}' | sed 's/M//')
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# --- 2. Construct the INSERT Statement ---
# Using a subquery to find host_id by hostname
# Note: Numeric values are not quoted, strings/timestamps are.
insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) 
VALUES('$timestamp', (SELECT id FROM host_info WHERE hostname='$hostname'), $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

# Optional: Print the data collected for debugging
echo "Collected data for $hostname at $timestamp"

# --- 3. Execute the INSERT Statement ---
export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

# Unset password for security
unset PGPASSWORD

exit $?
