#!/bin/bash
# Stop the pod and free the GPU for others. Data on /data/... is kept.
# Start again with ./start.sh
# Usage: ./stop.sh
set -euo pipefail
cd "$(dirname "$0")"
source ./_load_env.sh
kubectl scale "statefulset/$APPNAME" -n "$NAMESPACE" --replicas=0
echo "Stopped '$APPNAME'."
