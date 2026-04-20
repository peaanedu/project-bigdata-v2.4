#!/usr/bin/env bash
set -euo pipefail

export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-/opt/hadoop/etc/hadoop}"
export PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"

echo "Creating HDFS directories..."

for _ in $(seq 1 60); do
  if hdfs dfsadmin -report >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -mkdir -p /tmp/hive
hdfs dfs -mkdir -p /data/raw/sales

hdfs dfs -chmod -R 777 /user/hive
hdfs dfs -chmod -R 777 /tmp/hive
hdfs dfs -chmod -R 777 /data

if [ -f /datasets/sales_orders.csv ]; then
  hdfs dfs -put -f /datasets/sales_orders.csv /data/raw/sales/
fi

echo "HDFS initialization completed."
