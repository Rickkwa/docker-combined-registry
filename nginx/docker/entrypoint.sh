#!/bin/bash

# TODO: warn if these environment variables are

if [[ "$ENABLE_AUTH" == true ]]; then
    export BASIC_AUTH="auth_basic \"Docker registry login\";
auth_basic_user_file \"/etc/nginx/htpasswd\";"
fi

envsubst '$AGGREGATE_HOSTNAME:$BASIC_AUTH' < /etc/nginx/templates_conf.d/default.conf.tmpl > /etc/nginx/conf.d/default.conf
envsubst '$HOSTED_HOSTNAME' < /etc/nginx/templates_conf.d/hosted.conf.tmpl > /etc/nginx/conf.d/hosted.conf
envsubst '$PROXY_HOSTNAME' < /etc/nginx/templates_conf.d/proxy.conf.tmpl > /etc/nginx/conf.d/proxy.conf

exec /usr/bin/openresty -g "daemon off;"

