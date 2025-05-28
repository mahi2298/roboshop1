#!/bin/bash

echo "==== MEMORY USAGE ===="

# Get memory usage using 'free -h'
free -h

# Optional: Add usage percentage
echo
echo "==== MEMORY USAGE PERCENTAGE ===="
total=$(free -m | grep 'Mem:' | awk -F ' ' '{print $2F}')
used=$(free -m | grep 'Mem:' | awk -F ' ' '{print $3F}')
percent=$(awk "BEGIN {printf \"%.2f\", ($used/$total)*100}")
echo "Used: $used / $total ($percent%)"