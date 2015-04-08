#!/bin/bash
set -o errexit -o nounset -o pipefail

function main {
  while true; do
    sleep 1
    refresh_system_haproxy $MARATHON_HOSTS
  done
}

function refresh_system_haproxy {
  config "$@" > /tmp/haproxy.cfg
  if ! diff -q /tmp/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg >&2
  then
    msg "Found changes. Sending reload request to HAProxy..."
    cat /tmp/haproxy.cfg > /usr/local/etc/haproxy/haproxy.cfg
    supervisorctl restart haproxy
  fi
}

function config {
  header
  apps "$@"
}

function header {
cat <<\EOF
global
  daemon
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  maxconn 4096

defaults
  log            global
  retries             3
  maxconn          2000
  timeout connect  5000
  timeout client  50000
  timeout server  50000

listen stats
  bind 127.0.0.1:9090
  balance
  mode http
  stats enable
  stats auth admin:admin
EOF
}

function apps {
  (until curl -sSfLk -m 10 -H 'Accept: text/plain' "${1%/}"/v2/tasks; do [ $# -lt 2 ] && return 1 || shift; done) | while read -r txt
  do
    set -- $txt
    if [ $# -lt 2 ]; then
      shift $#
      continue
    fi

    local app_name="$1"
    local app_port="$2"
    shift 2

    if [ ! -z "${app_port##*[!0-9]*}" ]
    then
      cat <<EOF

listen $app_name-$app_port
  bind 0.0.0.0:$app_port
  mode tcp
  option tcplog
  balance leastconn
EOF
      while [[ $# -ne 0 ]]
      do
        out "  server ${app_name}-$# $1 check"
        shift
      done
    fi
  done
}

function msg { out "$*" >&2 ;}
function err { local x=$? ; msg "$*" ; return $(( $x == 0 ? 1 : $x )) ;}
function out { printf '%s\n' "$*" ;}

main