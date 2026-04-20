FROM apache/hive:4.0.0

ARG POSTGRES_JDBC_VERSION=42.7.3

USER root

RUN apt-get update     && apt-get install -y --no-install-recommends curl tini netcat-openbsd procps     && rm -rf /var/lib/apt/lists/*     && curl -fsSL -o "/opt/hive/lib/postgresql-${POSTGRES_JDBC_VERSION}.jar"        "https://jdbc.postgresql.org/download/postgresql-${POSTGRES_JDBC_VERSION}.jar"     && ln -sf "/opt/hive/lib/postgresql-${POSTGRES_JDBC_VERSION}.jar" /opt/hive/lib/postgresql.jar     && mkdir -p /opt/platform/bin /hive_custom_conf /opt/hive/scripts /tmp/hive-home

COPY bin/hive-entrypoint.sh /opt/platform/bin/hive-entrypoint.sh
RUN chmod +x /opt/platform/bin/hive-entrypoint.sh

ENTRYPOINT ["/usr/bin/tini","--","/opt/platform/bin/hive-entrypoint.sh"]
