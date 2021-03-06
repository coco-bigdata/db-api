#!/bin/sh

DIR=$(dirname "$0")/..
ROOT_DIR=`cd "$DIR"; pwd`
echo $ROOT_DIR
cd $ROOT_DIR
# VERSION=$(mvn -q -DforceStdout -N org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.version)
VERSION=3.0.0
echo $VERSION
TAG=${TAG:-"$VERSION"}

docker push yiluxiangbei/db-api:$TAG