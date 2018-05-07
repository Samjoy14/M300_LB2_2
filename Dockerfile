

FROM ubuntu:16.04
MAINTAINER Samjoy Sivagurunathan <samjoy.sivagurubathan@hotmail.ch>

# Installation & Konfiguration
RUN apt-get -qq update
RUN sed -i '$adeb https://github.com/chsliu/docker-webmin.git' /etc/apt/sources.list
RUN cd /root
RUN apt-get -y -qq install apt-transport-https
RUN apt-get -qq update
RUN apt-get -y install apt-utils
RUN rm /etc/apt/apt.conf.d/docker-gzip-indexes
RUN apt-get purge apt-show-versions
RUN apt-get -o Acquire::GzipIndexes=false update
RUN apt-get -y install apt-show-versions
RUN apt-get -y install webmin

HEALTHCHECK --interval=5m --timeout=3s CMD curl -f https://localhost:10000 || exit 1

EXPOSE 10000

CMD /usr/bin/touch /var/webmin/miniserv.log && /usr/sbin/service webmin restart && /usr/bin/tail -f /var/webmin/miniserv.log