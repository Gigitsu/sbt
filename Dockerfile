FROM docker:git

LABEL maintainer Gigitsu <gigitsu.23@gmail.com>

ENV LANG C.UTF-8

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

# Set environment

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV SCALA_HOME /usr/share/scala
ENV SBT_HOME /usr/lib/sbt

ENV PATH $PATH:$JAVA_HOME/jre/bin:$JAVA_HOME/bin:$SBT_HOME/bin:$SCALA_HOME/bin

ENV JAVA_VERSION 8u191
ENV JAVA_ALPINE_VERSION 8.191.12-r0

ENV SBT_VERSION=1.2.0
ENV SCALA_VERSION=2.12.6

RUN set -x \
	&& apk add --no-cache \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates && \
	apk add --no-cache bash && \
  cd /usr/lib && \
  wget -q --no-cookies https://piccolo.link/sbt-$SBT_VERSION.tgz -O - | gunzip | tar x && \
  cd /usr/share && \
  wget -q --no-cookies https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz -O - | gunzip | tar x && \
  mv /usr/share/scala-$SCALA_VERSION $SCALA_HOME && \
  apk del build-dependencies && \
  rm -rf /tmp/*

RUN sbt sbtVersion
