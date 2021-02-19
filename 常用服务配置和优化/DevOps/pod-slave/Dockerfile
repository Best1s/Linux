FROM jenkins/jnlp-slave
COPY apache-maven-3.3.9 /usr/local/apache-maven-3.3.9
COPY kubectl /bin/
COPY envsubst /bin/
COPY config /root/.kube/config
COPY node-v14.13.1-linux-x64 /usr/local/
COPY config.json /root/.docker/config.json
RUN mkdir -p  /tmp/build_log
RUN mkdir -p /tmp/rollback
ENV PATH $PATH:/usr/local/apache-maven-3.3.9/bin