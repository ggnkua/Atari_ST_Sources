#!/usr/bin/bash

msgfile="./LANGUES/FRANCAIS/VMSG.H"

echo "Messages not found in sources:"
#while IFS='' read -r line || [[ -n "$line" ]]; do
while IFS='' read -r line ; do
  y=$(echo $line | awk '{print $2}')
  n=$(grep -R --include=*.{c,C,h,H} --exclude=*VMSG.H $y ../TOOLS . | wc -l)
  if [ "$n" = "0" ]; then
    echo $y
  fi
done  < "$msgfile"
