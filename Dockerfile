FROM ubuntu:14.04
# not: debian:7.5 because chef-server needs GLIBC_2.14
MAINTAINER Ewa Czechowska <ewa@ai-traders.com>

#RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

RUN mkdir /scripts
# do not add any comments after ADD or COPY or you get: "no such file or directory"
COPY scripts /scripts 
RUN /scripts/install_chef_server.sh && mv /scripts/image_metadata.txt /etc/docker_image_metadata.txt && /scripts/cleanup.sh


EXPOSE 443
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/usr/bin/run_chef_server.sh"]

FROM debian:wheezy
MAINTAINER Steven Bower <sbower@alcyon.net>

ENV LANG C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -q -y --no-install-recommends curl \
    && curl -k -L -o /tmp/chefdk.deb "http://www.opscode.com/chef/download-chefdk?p=debian&pv=7&m=x86_64&v=latest&prerelease=false&nightlies=false" \
    && apt-get purge -q -y curl libldap-2.4-2 libsasl2-2 libgcrypt11 libgpg-error0 \
    && apt-get autoremove -q -y --purge \
    && apt-get clean -q -y \
    && rm -rf /var/lib/apt/lists/*

RUN export DEBIAN_FRONTEND=noninteractive \
    && dpkg -i /tmp/chefdk.deb
#&& rm /tmp/chefdk.deb
