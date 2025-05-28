#!/bin/bash

echo "==== MEMORY USAGE ===="

# Get memory usage using 'free -h'
free -h

# Optional: Add usage percentage
echo
echo "==== MEMORY USAGE PERCENTAGE ===="
total=$(free | awk '/^Mem:/ {print $2}')
used=$(free | awk '/^Mem:/ {print $3}')
percent=$(awk "BEGIN {printf \"%.2f\", ($used/$total)*100}")
echo "Used: $used / $total ($percent%)"