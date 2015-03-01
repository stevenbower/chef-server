FROM debian:7.5
MAINTAINER Ewa Czechowska <ewa@ai-traders.com>

RUN mkdir /scripts
# do not add any comments after ADD or COPY or you get: "no such file or directory"
COPY scripts /scripts 
RUN /scripts/install_chef_server.sh && mv /scripts/image_metadata.txt /etc/docker_image_metadata.txt && /scripts/cleanup.sh

RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

