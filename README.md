# Project Big Data v2.3 Production Pack

A stable, Docker Compose based Big Data lab with:

- Hadoop HDFS + YARN cluster
- 1 NameNode
- 3 DataNodes
- 1 ResourceManager
- 3 NodeManagers
- 1 JobHistory server
- PostgreSQL backed Hive Metastore
- Hive Metastore service
- HiveServer2
- Spark Master
- 2 Spark Workers
- Jupyter Lab with PySpark
- Trino query engine
- Sample dataset and ETL examples

## Directory layout

```text
.
├── .env.example
├── docker-compose.yml
├── README.md
├── datasets/
│   └── sales_orders.csv
├── hadoop/
│   ├── Dockerfile
│   ├── bin/
│   │   └── start-hadoop-role.sh
│   └── conf/
│       ├── core-site.xml
│       ├── hdfs-site.xml
│       ├── mapred-site.xml
│       ├── workers
│       └── yarn-site.xml
├── hive/
│   ├── Dockerfile
│   ├── bin/
│   │   └── hive-entrypoint.sh
│   └── conf/
│       ├── core-site.xml
│       ├── hdfs-site.xml
│       └── hive-site.xml
├── jupyter/
│   ├── Dockerfile
│   └── requirements.txt
├── notebooks/
│   └── etl_sales_to_parquet.py
├── scripts/
│   ├── healthcheck-http.sh
│   ├── healthcheck-tcp.sh
│   ├── init-hdfs.sh
│   ├── load_demo_data.sh
│   ├── validate-platform.sh
│   └── sql/
│       ├── 00_create_database.sql
│       ├── 01_create_external_sales_table.sql
│       └── 02_create_managed_parquet_table.sql
├── spark/
│   └── conf/
│       ├── spark-defaults.conf
│       └── spark-env.sh
└── trino/
    └── etc/
        ├── config.properties
        ├── jvm.config
        ├── node.properties
        └── catalog/
            └── hive.properties
```

## Prerequisites

- Ubuntu 22.04 or newer
- Docker Engine 24+
- Docker Compose plugin

## Quick start

```bash
cp .env.example .env
docker compose up -d --build
```

## What starts automatically

- PostgreSQL initializes the Hive metastore database
- NameNode formats itself only on the first run
- HDFS helper service creates:
  - `/user/hive/warehouse`
  - `/tmp/hive`
  - `/data/raw/sales`
- The sample CSV is uploaded to HDFS
- Hive metastore schema is initialized only if it does not already exist

## Core service URLs

- NameNode UI: `http://localhost:9870`
- ResourceManager UI: `http://localhost:8088`
- HistoryServer UI: `http://localhost:8188`
- Spark Master UI: `http://localhost:8080`
- Spark Worker 1 UI: `http://localhost:8082`
- Spark Worker 2 UI: `http://localhost:8083`
- Jupyter Lab: `http://localhost:8888` token from `.env`
- Trino UI / API: `http://localhost:8081`

## Validation

Run:

```bash
chmod +x scripts/*.sh
./scripts/validate-platform.sh
```

Manual checks:

```bash
docker compose ps
docker compose exec namenode hdfs dfsadmin -report
docker compose exec hive-server beeline -u jdbc:hive2://localhost:10000 -n hive
docker compose exec trino trino --execute "SHOW CATALOGS;"
```

## Load demo Hive tables

```bash
chmod +x scripts/load_demo_data.sh
./scripts/load_demo_data.sh
```

Then test:

```bash
docker compose exec hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -e "SHOW TABLES IN lab;"
docker compose exec trino trino --execute "SHOW SCHEMAS FROM hive;"
```

## Run the sample PySpark ETL

```bash
docker compose exec jupyter python /workspace/notebooks/etl_sales_to_parquet.py
```

## Troubleshooting

### Rebuild everything clean
```bash
docker compose down -v --remove-orphans
docker builder prune -f
docker volume prune -f
docker compose up -d --build
```

### Check Hive metastore
```bash
docker compose logs -f hive-metastore
```

### Check HiveServer2
```bash
docker compose logs -f hive-server
docker compose exec hive-server bash -lc "echo > /dev/tcp/127.0.0.1/10000 && echo OPEN || echo CLOSED"
```

### Check Trino
```bash
docker compose logs -f trino
docker compose exec trino trino --execute "SHOW CATALOGS;"
```

### Check HDFS paths
```bash
docker compose exec namenode hdfs dfs -ls /
docker compose exec namenode hdfs dfs -ls /data/raw/sales
```

### Common operational notes

- Do not paste YAML into XML config files.
- Do not mount single Hadoop XML files into read-only paths inside Trino.
- Do not run Hive schema initialization repeatedly against the same metastore database.
- Rebuild after changing Dockerfiles or image build logic.

## Power BI / JDBC

Use Trino as the SQL endpoint:

```text
jdbc:trino://localhost:8081/hive/default
```

## Recommended next upgrades

- Prometheus + Grafana monitoring
- Airflow orchestration
- MinIO or S3 compatible lake storage
- Kerberos and TLS hardening
