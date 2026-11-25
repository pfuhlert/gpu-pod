#!/bin/bash
# Open a shell in the running pod.
# Usage: ./shell.sh
set -euo pipefail
cd "$(dirname "$0")"
source ./_load_env.sh
kubectl exec -it "$APPNAME-0" -n "$NAMESPACE" -- zsh
