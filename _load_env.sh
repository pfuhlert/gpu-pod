# Sourced by the other scripts: load .env and check it is complete.
if [ ! -f .env ]; then
  echo "No .env file. Run: cp .env.example .env   and fill it in." >&2
  exit 1
fi
set -a
source .env
set +a
for v in APPNAME APPVERSION USERNAME USER_UID USER_GID GIT_NAME GIT_EMAIL NAMESPACE REMOTE_REGISTRY CPU MEMORY GPU; do
  if [ -z "${!v:-}" ]; then
    echo "'$v' is empty in .env" >&2
    exit 1
  fi
done
# Storage: either DATA_PVC, or DATA_NFS_SERVER together with DATA_NFS_PATH.
if [ -n "${DATA_PVC:-}" ] && [ -n "${DATA_NFS_SERVER:-}${DATA_NFS_PATH:-}" ]; then
  echo "Set either DATA_PVC or DATA_NFS_SERVER/DATA_NFS_PATH in .env, not both." >&2
  exit 1
fi
if [ -z "${DATA_PVC:-}" ] && { [ -z "${DATA_NFS_SERVER:-}" ] || [ -z "${DATA_NFS_PATH:-}" ]; }; then
  echo "No storage in .env: set DATA_PVC, or both DATA_NFS_SERVER and DATA_NFS_PATH." >&2
  exit 1
fi
if [[ "${DATA_SUBPATH:-}" == /* || "${DATA_SUBPATH:-}" == *..* ]]; then
  echo "DATA_SUBPATH must be a relative folder like 'students/anna' (no leading / and no '..')." >&2
  exit 1
fi
export DATA_PVC="${DATA_PVC:-}" DATA_NFS_SERVER="${DATA_NFS_SERVER:-}" DATA_NFS_PATH="${DATA_NFS_PATH:-}" DATA_SUBPATH="${DATA_SUBPATH:-}"
if ! [[ "$APPNAME" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]]; then
  echo "APPNAME '$APPNAME' must use only lowercase letters, digits and '-'." >&2
  exit 1
fi
