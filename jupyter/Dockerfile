FROM python:3.11-slim

RUN apt-get update     && apt-get install -y --no-install-recommends tini curl procps openjdk-17-jre-headless bash     && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PATH}
ENV PYSPARK_PYTHON=python3

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && rm /tmp/requirements.txt

WORKDIR /workspace

ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["bash","-lc","jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token=${JUPYTER_TOKEN:-bigdata123} --NotebookApp.password='' --notebook-dir=/workspace"]
