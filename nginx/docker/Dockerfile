FROM openresty/openresty:1.13.6.1-2-centos-rpm
EXPOSE 80 443

# Install opm modules
RUN opm get knyar/nginx-lua-prometheus=0.20171117

COPY ./docker/entrypoint.sh /opt/entrypoint.sh
COPY ./conf.d/ /etc/nginx/conf.d

ENTRYPOINT ["bash", "/opt/entrypoint.sh"]

