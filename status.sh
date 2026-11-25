#!/bin/bash
# Show the pod state and its most recent events (useful if it hangs in Pending).
# Usage: ./status.sh
set -euo pipefail
cd "$(dirname "$0")"
source ./_load_env.sh
kubectl get pod "$APPNAME-0" -n "$NAMESPACE" -o wide || true
echo
kubectl describe pod "$APPNAME-0" -n "$NAMESPACE" | sed -n '/^Events:/,$p' || true
