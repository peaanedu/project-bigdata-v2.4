#!/bin/bash

set -e

export HADOOP_HOME=/opt/hadoop
export PATH=$PATH:$HADOOP_HOME/bin

echo "⏳ Waiting for HDFS to be ready..."

# wait until HDFS is fully ready
until hdfs dfsadmin -report >/dev/null 2>&1; do
  echo "HDFS not ready yet... retrying"
  sleep 5
done

echo "✅ HDFS is READY"

# create directories (ignore if already exist)
hdfs dfs -mkdir -p /user/hive/warehouse || true
hdfs dfs -mkdir -p /tmp/hive || true

# permissions
hdfs dfs -chmod -R 777 /user || true
hdfs dfs -chmod -R 777 /tmp || true

echo "🎉 HDFS INIT COMPLETED SUCCESSFULLY"