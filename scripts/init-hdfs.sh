hdfs-init:
  image: project-bigdata/hadoop:3.3.6   # 🚨 DO NOT inherit entrypoint
  container_name: hdfs-init
  restart: "no"
  depends_on:
    - namenode
    - datanode1
    - datanode2
    - datanode3
  entrypoint: ["/bin/bash", "-c"]
  command: >
    export HADOOP_HOME=/opt/hadoop &&
    export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin &&
    echo '⏳ Waiting for HDFS...' &&
    until hdfs dfsadmin -report >/dev/null 2>&1; do
      echo 'HDFS not ready yet...';
      sleep 5;
    done &&
    hdfs dfs -mkdir -p /user/hive/warehouse &&
    hdfs dfs -mkdir -p /tmp/hive &&
    hdfs dfs -chmod -R 777 /user &&
    hdfs dfs -chmod -R 777 /tmp &&
    echo '🎉 HDFS INIT DONE'
  environment:
    TZ: Asia/Phnom_Penh
  volumes:
    - ./hadoop/conf:/opt/hadoop/etc/hadoop:ro
    - ./datasets:/datasets:ro
  networks:
    - bigdata