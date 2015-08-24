#!/bin/bash

set -m
CONFIG_FILE="/config/config.toml"
INFLUX_HOST="localhost"
INFLUX_API_PORT="8086"
API_URL="http://${INFLUX_HOST}:${INFLUX_API_PORT}"

# Dynamically change the value of 'max-open-shards' to what 'ulimit -n' returns
sed -i "s/^max-open-shards.*/max-open-shards = $(ulimit -n)/" ${CONFIG_FILE}

# Add UDP support
if [ -n "${UDP_DB}" ]; then
    sed -i -r -e "/^\[udp\]/, /^$/ { s/false/true/; s/#//g; s/\"udpdb\"/\"${UDP_DB}\"/g; }" ${CONFIG_FILE}
fi
if [ -n "${UDP_PORT}" ]; then
    sed -i -r -e "/^\[udp\]/, /^$/ { s/4444/${UDP_PORT}/; }" ${CONFIG_FILE}
fi


echo "influxdb configuration: "
cat ${CONFIG_FILE}
echo "=> Starting InfluxDB ..."
exec /opt/influxdb/influxd -config=${CONFIG_FILE} &

ADMIN_USER=${INFLUXDB_ADMIN_USER:-root}
ADMIN_PASS=${INFLUXDB_ADMIN_PASS:-root}
echo "=> Creating admin user"
/opt/influxdb/influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="CREATE USER ${ADMIN_USER} WITH PASSWORD '${ADMIN_PASS}' WITH ALL PRIVILEGES"

fg
