#!/bin/sh

MEMCACHED_HOST='127.0.0.1'
MEMCACHED_PORT=22422
MEMCACHED_BIN='/usr/bin/memcached'
MEMCACHED_OPTS="-m 64 -p ${MEMCACHED_PORT} -u memcache -l ${MEMCACHED_HOST} -d"
MEMCACHED_CMD="$MEMCACHED_BIN $MEMCACHED_OPTS"

ps aux | grep memcached | grep -v grep | grep ${MEMCACHED_PORT} | awk '{print $2}' | xargs kill -9
sleep 1
$MEMCACHED_CMD
echo "Memcache test server started."
exit 0


