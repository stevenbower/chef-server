FROM ubuntu:14.04
MAINTAINER Steven Bower <sbower@alcyon.net>
ENV LANG C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -q -y --no-install-recommends curl \
    && curl -k -L -o /tmp/chef-server.deb "http://www.opscode.com/chef/download-server?p=ubuntu&pv=12.04&m=x86_64&v=latest&prerelease=false&nightlies=false" \
    && dpkg -i /tmp/chef-server.deb
    && rm /tmp/chef-server.deb
    && apt-get purge -q -y curl libldap-2.4-2 libsasl2-2 libgcrypt11 libgpg-error0 \
    && apt-get autoremove -q -y --purge \
    && apt-get clean -q -y \
    && rm -rf /var/lib/apt/lists/* \
    && dpkg-divert --local --rename --add /sbin/initctl
    && ln -sf /bin/true /sbin/initctl

ADD reconfigure_chef.sh /usr/local/bin/
ADD run.sh /usr/local/bin/

CMD rsyslogd -n

VOLUME /root/
VOLUME /var/log

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["run.sh"]
