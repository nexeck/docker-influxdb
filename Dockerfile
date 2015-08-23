FROM ubuntu:trusty
MAINTAINER Marcel Beck <marcelbeck@outlook.com>

RUN apt-get update && apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists

# Install InfluxDB
ENV INFLUXDB_VERSION 0.9.2.1
RUN curl -s -o /tmp/influxdb_latest_amd64.deb https://s3.amazonaws.com/influxdb/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
  dpkg -i /tmp/influxdb_latest_amd64.deb && \
  rm /tmp/influxdb_latest_amd64.deb && \
  rm -rf /var/lib/apt/lists/*

ADD config.toml /config/config.toml
ADD run.sh /run.sh
RUN chmod +x /*.sh

# Admin server WebUI
EXPOSE 8083

# HTTP API
EXPOSE 8086

VOLUME ["/data"]

CMD ["/run.sh"]
