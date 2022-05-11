#!/usr/bin/env bash

set -ev

TRAVIS_DIR=`dirname $0`
HDFS_VERSION=$1

sh ${TRAVIS_DIR}/install-hdfs.sh $HDFS_VERSION
sh ${TRAVIS_DIR}/start-etcd.sh
echo "Installing requirments..."


