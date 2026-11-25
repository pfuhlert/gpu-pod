# Sourced by the other scripts: load .env and check it is complete.
if [ ! -f .env ]; then
  echo "No .env file. Run: cp .env.example .env   and fill it in." >&2
  exit 1
fi
set -a
source .env
set +a
for v in APPNAME APPVERSION USERNAME USER_UID USER_GID GIT_NAME GIT_EMAIL NAMESPACE REMOTE_REGISTRY DATA_PVC CPU MEMORY GPU; do
  if [ -z "${!v:-}" ]; then
    echo "'$v' is empty in .env" >&2
    exit 1
  fi
done
if ! [[ "$APPNAME" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]]; then
  echo "APPNAME '$APPNAME' must use only lowercase letters, digits and '-'." >&2
  exit 1
fi
