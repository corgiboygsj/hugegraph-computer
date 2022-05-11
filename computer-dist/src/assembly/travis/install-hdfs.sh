#!/bin/bash

set -ev

UBUNTU_VERSION=$(lsb_release -r | awk '{print substr($2,0,2)}')

tee /etc/apt/sources.list.d/hdp.list <<EOF
deb http://public-repo-1.hortonworks.com/HDP/ubuntu${UBUNTU_VERSION}/2.x/updates/2.6.5.0 HDP main
EOF

apt-get update

mkdir -p /etc/hadoop/conf
tee /etc/hadoop/conf/core-site.xml <<EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:8020</value>
    </property>
</configuration>
EOF

tee /etc/hadoop/conf/hdfs-site.xml <<EOF
<configuration>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/opt/hdfs/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hdfs/data</value>
    </property>
    <property>
        <name>dfs.permissions.superusergroup</name>
        <value>hadoop</value>
    </property>
    <property>
        <name>dfs.support.append</name>
        <value>true</value>
    </property>
</configuration>
EOF

apt-get install -y --allow-unauthenticated hadoop hadoop-hdfs

mkdir -p /opt/hdfs/data /opt/hdfs/name
chown -R hdfs:hdfs /opt/hdfs
-u hdfs hdfs namenode -format -nonInteractive

adduser travis hadoop

/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh start datanode
/usr/hdp/current/hadoop-hdfs-namenode/../hadoop/sbin/hadoop-daemon.sh start namenode

hdfs dfsadmin -safemode wait
