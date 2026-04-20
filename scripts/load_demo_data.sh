#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /opt/platform/scripts/sql/00_create_database.sql
docker compose exec -T hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /opt/platform/scripts/sql/01_create_external_sales_table.sql
docker compose exec -T hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /opt/platform/scripts/sql/02_create_managed_parquet_table.sql
