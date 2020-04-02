FROM   openjdk:8
#FROM  java:8
LABEL authors="Brugnara <martin.brugnara@gmail.com>, Matteo Lissandrini <ml@disi.unitn.eu>, Nolan Nichols <nolan.nichols@gmail.com>"

RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys CD8CB0F1E0AD5B52E93F41E7EA93F5E56E751E9B

ENV GREMLIN3_TAG 3.4.6
ENV HADOOP_TAG 3.2.1

ENV GREMLIN3_HOME /opt/gremlin
ENV HADOOP_HOME /opt/hadoop-${HADOOP_TAG}

ENV APACHE_MIRROR https://ftp.halifax.rwth-aachen.de/apache

ENV PATH /opt/gremlin/bin:$PATH


RUN apt-get -q  update && \
    apt-get -q  upgrade -y && \
    apt-get -q  install -y --no-install-recommends \
        build-essential \
        libstdc++6 \
        libgoogle-perftools4 \
        ca-certificates \
        pwgen \
        openssl \
        curl \
        bash \
        maven \
        unzip \
        git-core \
        openjfx \
        nano

RUN curl -L -o /tmp/gremlin.zip \
    ${APACHE_MIRROR}/tinkerpop/${GREMLIN3_TAG}/apache-tinkerpop-gremlin-console-${GREMLIN3_TAG}-bin.zip && \
    unzip -q /tmp/gremlin.zip -d /opt/ && \
    rm /tmp/gremlin.zip && \
    ln -s /opt/apache-tinkerpop-gremlin-console-${GREMLIN3_TAG} ${GREMLIN3_HOME}

RUN curl -L -o /tmp/hadoop-${HADOOP_TAG}.tar.gz \
    http://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_TAG}/hadoop-${HADOOP_TAG}.tar.gz && \
    tar -xf /tmp/hadoop-${HADOOP_TAG}.tar.gz -C /opt/ && \
    rm /tmp/hadoop-${HADOOP_TAG}.tar.gz
    
RUN export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::") && \
    echo $JAVA_HOME && \ 
    sed -i 's@=\${JAVA_HOME}@=\$\(readlink -f /usr/bin/java | sed "s:bin/java::"\)@' /opt/hadoop-${HADOOP_TAG}/etc/hadoop/hadoop-env.sh 

COPY extra/mapred-site.xml /opt/hadoop-${HADOOP_TAG}/etc/hadoop/


RUN curl -L -o /tmp/ldbc_snb_datagen.zip \
    https://github.com/ldbc/ldbc_snb_datagen/archive/master.zip && \
    unzip -q /tmp/ldbc_snb_datagen.zip -d /opt/ && \
    rm /tmp/ldbc_snb_datagen.zip 

ENV HADOOP_CLIENT_OPTS "-Xmx2G"
ENV LDBC_SNB_DATAGEN_HOME /opt/ldbc_snb_datagen-master

COPY extra/ldbc.params.ini /tmp/params.ini


RUN mv /tmp/params.ini /opt/ldbc_snb_datagen-master/params.ini  && \
    mkdir /tmp/ldbc-out 

WORKDIR /opt/ldbc_snb_datagen-master/

COPY extra/safe.sh /tmp/safe.sh

RUN cat /tmp/safe.sh |  cat - /opt/ldbc_snb_datagen-master/run.sh > /tmp/run.sh && \
    mv /tmp/run.sh /opt/ldbc_snb_datagen-master/run.sh && \
    chmod 755  /opt/ldbc_snb_datagen-master/run.sh 

RUN /opt/ldbc_snb_datagen-master/run.sh | grep -v Download

COPY extra/.groovy /root/.groovy
COPY extra/activate-sugar-tp3.groovy /tmp/

RUN  ${GREMLIN3_HOME}/bin/gremlin.sh -e /tmp/activate-sugar-tp3.groovy

RUN mv /tmp/ldbc-out/social_network/static/* /tmp/ldbc-out/social_network/
RUN mv /tmp/ldbc-out/social_network/dynamic/* /tmp/ldbc-out/social_network/
RUN ls -hl /tmp/ldbc-out/*


WORKDIR /runtime

CMD ["gremlin.sh", "-e", "/runtime/ldbc.groovy"]
#CMD ["bash"]
