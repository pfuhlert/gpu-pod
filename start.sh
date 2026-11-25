#!/bin/bash
# Deploy (or update) the StatefulSet and restart the pod with the current image.
# Everything outside the mounted /data/... folders is lost on restart.
# Usage: ./start.sh
set -euo pipefail
cd "$(dirname "$0")"
source ./_load_env.sh

echo "Deploying '$APPNAME:$APPVERSION' to namespace '$NAMESPACE' ..."
envsubst '$APPNAME $APPVERSION $REMOTE_REGISTRY $NAMESPACE $DATA_PVC $USER_UID $USER_GID $CPU $MEMORY $GPU' \
  < statefulset.yaml | kubectl apply -f -

kubectl rollout restart "statefulset/$APPNAME" -n "$NAMESPACE"
echo "Waiting for the pod to start (this can take a few minutes the first time) ..."
kubectl rollout status "statefulset/$APPNAME" -n "$NAMESPACE" --timeout=15m

echo "Ready. Open a shell with ./shell.sh"
