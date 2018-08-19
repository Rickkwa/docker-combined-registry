#!/bin/bash

# TODO: warn if these environment variables are not set

envsubst '$AGGREGATE_HOSTNAME' < /etc/nginx/templates_conf.d/default.conf.tmpl > /etc/nginx/conf.d/default.conf
envsubst '$HOSTED_HOSTNAME' < /etc/nginx/templates_conf.d/hosted.conf.tmpl > /etc/nginx/conf.d/hosted.conf
envsubst '$PROXY_HOSTNAME' < /etc/nginx/templates_conf.d/proxy.conf.tmpl > /etc/nginx/conf.d/proxy.conf

exec /usr/bin/openresty -g "daemon off;"

