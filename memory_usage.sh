#!/bin/bash

echo "==== MEMORY USAGE ===="

# Get memory usage using 'free -h'
free -h

# Optional: Add usage percentage

echo "==== MEMORY USAGE PERCENTAGE ===="
total=$(free -m | grep 'Mem:' | awk '{print $2}')
used=$(free -m | grep 'Mem:' | awk '{print $3}')
percent=$(awk "BEGIN {printf \"%.2f\", ($used/$total)*100}")
echo "Used: $used / $total ($percent%)"