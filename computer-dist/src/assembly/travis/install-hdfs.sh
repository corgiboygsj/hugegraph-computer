#!/usr/bin/env bash

set -ev

echo "Starting install hdfs"
TRAVIS_DIR=`dirname $0`
HDFS_VERSION=$1
HDFS_URL=https://dlcdn.apache.org/hadoop/common/hadoop-${HDFS_VERSION}/hadoop-${HDFS_VERSION}.tar.gz

echo "Download with url: ${HDFS_URL}"
wget -O ${TRAVIS_DIR}/hdfs.tar.gz ${HDFS_URL}
mkdir ${TRAVIS_DIR}/hdfs
tar -zxvf ${TRAVIS_DIR}/hdfs.tar.gz -C ${TRAVIS_DIR}/hdfs --strip-components 1

HDFS_HOME=${TRAVIS_DIR}/hdfs

tee ${HDFS_HOME}/etc/hadoop/core-site.xml <<EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
EOF

tee ${HDFS_HOME}/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.secondary.http.address</name>
        <value>localhost:9100</value>
    </property>
</configuration>
EOF

chmod g-w $HOME                                 &&
chmod o-w $HOME                                 &&
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa        &&
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys &&
chmod 0600 ~/.ssh/authorized_keys               &&
ssh-keyscan -H localhost >> ~/.ssh/known_hosts  &&
chmod 0600 ~/.ssh/known_hosts                   &&
eval \`ssh-agent\`                              &&
ssh-add ~/.ssh/id_rsa

export HADOOP_HOME=${HDFS_HOME}
export HDFS_NAMENODE_ADDR=127.0.0.1:9000
export PATH=$HADOOP_HOME/bin:$PATH

${HDFS_HOME}/bin/hdfs namenode -format
${HDFS_HOME}/sbin/start-dfs.sh
