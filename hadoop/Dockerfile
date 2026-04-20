FROM eclipse-temurin:11-jre-jammy

ARG HADOOP_VERSION=3.3.6

RUN apt-get update     && apt-get install -y --no-install-recommends curl procps netcat-openbsd python3 tini bash     && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"     | tar -xz -C /opt     && mv "/opt/hadoop-${HADOOP_VERSION}" /opt/hadoop

ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV PATH=/opt/hadoop/bin:/opt/hadoop/sbin:${PATH}
ENV JAVA_HOME=/opt/java/openjdk

RUN mkdir -p /var/lib/hadoop/hdfs/namenode     /var/lib/hadoop/hdfs/datanode     /var/log/hadoop     /opt/platform/scripts

COPY bin/start-hadoop-role.sh /usr/local/bin/start-hadoop-role.sh
RUN chmod +x /usr/local/bin/start-hadoop-role.sh

ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/start-hadoop-role.sh"]
