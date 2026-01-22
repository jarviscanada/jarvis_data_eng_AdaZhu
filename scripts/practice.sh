# save hostname as a variable
hostname=$(hostname -f)

# save the number of CPUs to a variable
lscpu_out=`lscpu`
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
# tip: `xargs` is a trick to remove leading and trailing white spaces
# tip: the $2 is instructing awk to find the second field

# hardware info
hostname=
cpu_number=
cpu_architecture=
cpu_model=
cpu_mhz=
l2_cache=
total_mem= $(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp= # current timestamp in `2019-11-26 14:40:19` format; use `date` cmd
# hardware info
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | awk -F: '{print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | egrep "^CPU MHz:" | awk '{print $3}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | sed 's/K//' | xargs)
total_mem=$(cat /proc/meminfo | egrep "^MemTotal:" | awk '{print $2/1024}' | xargs | cut -d. -f1)
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# usage info
memory_free=$(vmstat --unit M | tail -1 | awk -v col="4" '{print $col}')
cpu_idle=
cpu_kernel=
disk_io=$(vmstat --unit M -d | tail -1 | awk -v col="10" '{print $col}')
disk_available=
# usage info
memory_free=$(vmstat --unit M | tail -1 | awk '{print $4}' | xargs)
cpu_idle=$(vmstat | tail -1 | awk '{print $15}' | xargs)
cpu_kernel=$(vmstat | tail -1 | awk '{print $14}' | xargs)
disk_io=$(vmstat -d | tail -1 | awk '{print $10}' | xargs)
disk_available=$(df -BM / | tail -1 | awk '{print $4}' | sed 's/M//' | xargs)
