FROM docker:git

ENV LANG C.UTF-8

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u181
ENV JAVA_ALPINE_VERSION 8.181.13-r0

RUN set -x \
	&& apk add --no-cache \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

# Set environment
ENV SBT_HOME /usr/lib/sbt
ENV PATH $PATH:$SBT_HOME/bin

RUN apk add --no-cache bash \
  && apk add --no-cache --virtual=build-dependencies wget ca-certificates \
  && cd /usr/lib \
  && wget -q --no-cookies https://dl.bintray.com/sbt/native-packages/sbt/0.13.12/sbt-0.13.12.tgz -O - | gunzip | tar x \
  && apk del build-dependencies \
  && rm -rf /tmp/*

RUN sbt sbtVersion