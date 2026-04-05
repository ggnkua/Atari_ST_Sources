#!/bin/bash -u
# -u: Treat unset variables as an error when substituting.

# Purpose: Purge old snapshots
# Input: output of lftp "ls" command
# Output: lftp "rm -r" commands

# Number of days of retention before purge
days_retention=7

# But always keep a minimal number of snapshots
min_keep=5

# Every snapshot up to this day will be purged
last_day_purge=$(date -u +%Y%m%d --date "$days_retention days ago")

# Current number of snapshots kept
n=0

# Read each remote file, as output from lftp "ls" command
while read flags links user group size month day hour f
do
  # Skip non-snapshots
  if [[ ! $f =~ ^[0-9]*-[0-9]*-[0-9a-z]* ]]
  then
    continue
  fi

  echo $f

  # Then reverse sort to have last snapshots first
done | sort -r | while read f
do
  # This is one more snapshot
  (( n++ ))

  # Do not purge until minimal number of snapshots
  if [ $n -le $min_keep ]
  then
    echo "echo '#keep $f'"
    continue
  fi

  # Purge old snapshots
  day=$(echo $f | cut -d - -f 1)
  if [ $day -le $last_day_purge ]
  then
    echo "echo 'rm -r $f'"
    echo "rm -r $f"
  else
    echo "echo '#keep $f'"
  fi
done
