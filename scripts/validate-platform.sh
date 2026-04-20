#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] HDFS report"
docker compose exec -T namenode hdfs dfsadmin -report >/dev/null

echo "[2/5] YARN info"
docker compose exec -T resourcemanager bash -lc "curl -fsS http://localhost:8088/ws/v1/cluster/info >/dev/null"

echo "[3/5] HiveServer2"
docker compose exec -T hive-server bash -lc "echo > /dev/tcp/127.0.0.1/10000"

echo "[4/5] Trino catalogs"
docker compose exec -T trino trino --execute "SHOW CATALOGS;" >/dev/null

echo "[5/5] Spark master UI"
docker compose exec -T spark-master python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080', timeout=5)"

echo "Validation completed successfully."
