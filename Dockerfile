FROM openjdk:11-slim

ENV VERSION 5.0.5
ENV LIBJPEGTURBO 2.1.2
EXPOSE 80

RUN apt-get update && apt-get install -y --no-install-recomennds curl unzip gettext-base jq libopenjp2-tools cmake nasm && rm -rf /var/lib/apt/lists/*

ENV CANTALOUPE_PROPERTIES="/etc/cantaloupe.properties"

RUN adduser --system --home /opt/cantaloupe cantaloupe

# Install libjpeg-turbo
RUN curl -L "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/$LIBJPEGTURBO.zip" > /tmp/libjpegturbo.zip \
  && unzip /tmp/libjpegturbo.zip -d /tmp \
  && cd /tmp/libjpeg-turbo-$LIBJPEGTURBO \
  && cmake -G"Unix Makefiles" -DWITH_JAVA=1 \
  && make \
  && mkdir -p /opt/libjpeg-turbo/lib/ \
  && cp libturbojpeg.so /opt/libjpeg-turbo/lib/libturbojpeg.so

# Retrieve Cantaloupe executable
RUN curl -L "https://github.com/cantaloupe-project/cantaloupe/releases/download/v$VERSION/cantaloupe-$VERSION.zip" > /tmp/cantaloupe.zip \
  && mkdir -p /usr/local/ \
  && cd /usr/local \
  && unzip /tmp/cantaloupe.zip -d /usr/local \
  && ln -s cantaloupe-$VERSION cantaloupe \
  && rm /tmp/cantaloupe.zip \
  && cp /usr/local/cantaloupe-$VERSION/deps/Linux-x86-64/lib/* /lib

COPY cantaloupe.properties /etc/cantaloupe.properties
RUN mkdir -p /var/log/cantaloupe \
 && mkdir -p /var/cache/cantaloupe \
 && chown -R cantaloupe /var/log/cantaloupe \
 && chown -R cantaloupe /var/cache/cantaloupe \
 && chown cantaloupe /etc/cantaloupe.properties

RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
  && chown -R cantaloupe /var/log/cantaloupe /var/cache/cantaloupe /opt/cantaloupe

USER cantaloupe
CMD java -Dcantaloupe.config=$CANTALOUPE_PROPERTIES -Xmx2g -jar /usr/local/cantaloupe/cantaloupe-$VERSION.jar
