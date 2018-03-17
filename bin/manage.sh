#!/bin/bash

consul() {
    export CONSUL_AGENT_BIND_ADDR=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
    echo "Exported CONSOUL_AGENT_BIND_ADDR to $CONSUL_AGENT_BIND_ADDR ..."

    /usr/local/bin/consul agent \
        -bind=$CONSUL_AGENT_BIND_ADDR \
        -advertise=$CONSUL_AGENT_BIND_ADDR \
        -data-dir=/data \
        -config-dir=/config \
        -log-level=info \
        -rejoin \
        -retry-join=$CONSUL_SERVER \
        -retry-max=10 \
        -retry-interval=10s
}

onStart() {
    logDebug "onStart"

    logDebug "Running consul-template ..."
    if [[ ! -f /etc/gnatsd.conf ]]; then
        consul-template -consul-addr=localhost:8500 -once -template=/etc/gnatsd.conf.tmpl:/etc/gnatsd.conf
        if [[ $? != 0 ]]; then
            exit 1
        fi
    fi
}

onChange() {
    logDebug "onChange"

    consul-template -consul-addr=localhost:8500 -once -template=/etc/gnatsd.conf.tmpl:/etc/gnatsd.conf
    pkill -SIGHUP gnatsd
}

health() {
    logDebug "health"

    /usr/bin/curl -o /dev/null --fail -s http://127.0.0.1:8222/varz
    if [[ $? -ne 0 ]]; then
        echo "NATS monitor endpoint failed"
        exit 1
    fi
}

logDebug() {
    if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
        echo "manage: $*"
    fi
}

until
    cmd=$1
    if [[ -z "$cmd" ]]; then
        help
    fi
    shift 1
    $cmd "$@"
    [ "$?" -ne 127 ]
do
    help
    exit
done
