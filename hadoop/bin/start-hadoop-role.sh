#!/usr/bin/env bash
set -euo pipefail

ROLE="${HADOOP_ROLE:-client}"

export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-/opt/hadoop/etc/hadoop}"
export PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"
export JAVA_HOME="${JAVA_HOME:-/opt/java/openjdk}"

ensure_hadoop_env() {
  grep -q 'JAVA_HOME=' "${HADOOP_CONF_DIR}/hadoop-env.sh" && \
    sed -i "s|^export JAVA_HOME=.*|export JAVA_HOME=${JAVA_HOME}|" "${HADOOP_CONF_DIR}/hadoop-env.sh" || \
    echo "export JAVA_HOME=${JAVA_HOME}" >> "${HADOOP_CONF_DIR}/hadoop-env.sh"
}

wait_for_namenode() {
  local retries="${1:-60}"
  until curl -fsS "http://namenode:9870" >/dev/null 2>&1; do
    retries=$((retries-1))
    if [ "${retries}" -le 0 ]; then
      echo "NameNode did not become ready in time" >&2
      exit 1
    fi
    sleep 2
  done
}

format_namenode_if_needed() {
  if [ ! -d /var/lib/hadoop/hdfs/namenode/current ]; then
    echo "Formatting NameNode metadata..."
    hdfs namenode -format -force -nonInteractive cluster-lab
  fi
}

ensure_hadoop_env

case "${ROLE}" in
  namenode)
    format_namenode_if_needed
    exec hdfs namenode
    ;;
  datanode)
    wait_for_namenode
    exec hdfs datanode
    ;;
  resourcemanager)
    wait_for_namenode
    exec yarn resourcemanager
    ;;
  nodemanager)
    wait_for_namenode
    exec yarn nodemanager
    ;;
  historyserver)
    wait_for_namenode
    exec mapred historyserver
    ;;
  client)
    exec "$@"
    ;;
  *)
    echo "Unknown HADOOP_ROLE: ${ROLE}" >&2
    exit 1
    ;;
esac
