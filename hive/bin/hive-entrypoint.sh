#!/usr/bin/env bash
set -euo pipefail

export HOME="${HOME:-/tmp/hive-home}"
mkdir -p "${HOME}"

export HIVE_CONF_DIR="/opt/hive/conf"
export HADOOP_CONF_DIR="/opt/hive/conf"
export TEZ_CONF_DIR="/opt/hive/conf"
export HIVE_AUX_JARS_PATH="${HIVE_AUX_JARS_PATH:-/opt/hive/lib/postgresql.jar}"

if [ -d "${HIVE_CUSTOM_CONF_DIR:-/hive_custom_conf}" ]; then
  find "${HIVE_CUSTOM_CONF_DIR:-/hive_custom_conf}" -type f -exec ln -sfn {} /opt/hive/conf/ \;
fi

schema_exists() {
  /opt/hive/bin/schematool -dbType postgres -info >/dev/null 2>&1
}

initialize_schema_if_needed() {
  if [ "${SKIP_SCHEMA_INIT:-false}" = "true" ]; then
    echo "Skipping Hive schema initialization."
    return
  fi

  if schema_exists; then
    echo "Hive metastore schema already present; skipping init."
  else
    echo "Initializing Hive metastore schema..."
    /opt/hive/bin/schematool -dbType postgres -initSchema
  fi
}

case "${SERVICE_NAME:-}" in
  metastore)
    initialize_schema_if_needed
    exec /opt/hive/bin/hive --skiphadoopversion --skiphbasecp --service metastore
    ;;
  hiveserver2)
    export HADOOP_CLASSPATH="/opt/tez/*:/opt/tez/lib/*:${HADOOP_CLASSPATH:-}"
    exec /opt/hive/bin/hive --skiphadoopversion --skiphbasecp --service hiveserver2
    ;;
  *)
    echo "SERVICE_NAME must be set to metastore or hiveserver2" >&2
    exit 1
    ;;
esac
