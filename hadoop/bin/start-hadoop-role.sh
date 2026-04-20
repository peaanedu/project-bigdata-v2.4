#!/usr/bin/env bash
set -euo pipefail

export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
export JAVA_HOME=${JAVA_HOME:-/opt/java/openjdk}
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

ROLE="${HADOOP_ROLE:-namenode}"

mkdir -p /data/dfs/name /data/dfs/data /data/yarn /data/mr-history

case "$ROLE" in
  namenode)
    if [ ! -d "/data/dfs/name/current" ]; then
      echo "Formatting NameNode..."
      hdfs namenode -format -force -nonInteractive
    fi
    exec hdfs namenode
    ;;
  datanode)
    exec hdfs datanode
    ;;
  resourcemanager)
    exec yarn resourcemanager
    ;;
  nodemanager)
    exec yarn nodemanager
    ;;
  historyserver)
    exec mapred historyserver
    ;;
  *)
    echo "Unknown HADOOP_ROLE: $ROLE"
    exit 1
    ;;
esac