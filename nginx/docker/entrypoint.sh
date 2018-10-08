#!/bin/bash

# Ensure required variables are set
REQUIRED_VARS=("AGGREGATE_HOSTNAME" "HOSTED_HOSTNAME" "PROXY_HOSTNAME")
for var in ${REQUIRED_VARS[@]}; do
    if [[ -z "${!var}" ]]; then
        echo "${var} is required but is not set." 1>&2
        exit 1
    fi
done

# Handle Nginx basic authentication flag
if [[ "$ENABLE_AUTH" == true ]]; then
    export BASIC_AUTH="auth_basic \"Docker registry login\";
auth_basic_user_file \"/etc/nginx/htpasswd\";"
fi

# Template nginx configuration files
envsubst '$AGGREGATE_HOSTNAME:$BASIC_AUTH' < /etc/nginx/templates_conf.d/default.conf.tmpl > /etc/nginx/conf.d/default.conf
envsubst '$HOSTED_HOSTNAME' < /etc/nginx/templates_conf.d/hosted.conf.tmpl > /etc/nginx/conf.d/hosted.conf
envsubst '$PROXY_HOSTNAME' < /etc/nginx/templates_conf.d/proxy.conf.tmpl > /etc/nginx/conf.d/proxy.conf

exec /usr/bin/openresty -g "daemon off;"

