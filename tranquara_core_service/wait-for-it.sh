#!/bin/sh
# wait-for-it.sh: Wait for services to be available before starting the application
# Usage: ./wait-for-it.sh host:port [host:port ...] -- command

set -e

TIMEOUT=60
QUIET=0

wait_for() {
  host="$1"
  port="$2"
  
  echo "Waiting for $host:$port..."
  
  start_ts=$(date +%s)
  while :
  do
    if nc -z "$host" "$port" > /dev/null 2>&1; then
      end_ts=$(date +%s)
      echo "$host:$port is available after $((end_ts - start_ts)) seconds"
      return 0
    fi
    
    sleep 1
    
    end_ts=$(date +%s)
    if [ $((end_ts - start_ts)) -ge $TIMEOUT ]; then
      echo "Timeout waiting for $host:$port"
      return 1
    fi
  done
}

# Parse arguments
HOSTS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --)
      shift
      break
      ;;
    *)
      HOSTS="$HOSTS $1"
      shift
      ;;
  esac
done

# Wait for each host:port
for hostport in $HOSTS; do
  host=$(echo "$hostport" | cut -d: -f1)
  port=$(echo "$hostport" | cut -d: -f2)
  wait_for "$host" "$port"
done

# Execute the command
exec "$@"
