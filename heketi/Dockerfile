FROM centos:7

LABEL architecture="x86_64"
LABEL io.k8s.display-name="Heketi 5"
LABEL io.k8s.description="This image provides Heketi, a RESTful management interface which can be used to manage Gluster volumes."
LABEL io.openshift.tags="cns,heketi"

ENV container docker

ADD *.repo /etc/yum.repos.d/

RUN yum install -y heketi heketi-client python-heketi && \
    yum update -y && \
    yum -y clean all

# post install config and volume setup
ADD ./heketi.json /etc/heketi/heketi.json

# add startup script which copies the backup db
ADD ./heketi-start.sh /usr/sbin/heketi-start.sh
RUN chmod 555 /usr/sbin/heketi-start.sh

VOLUME /etc/heketi
VOLUME /var/lib/heketi

# expose port, set user and set entrypoint with config option
EXPOSE 8080
ENTRYPOINT ["/usr/sbin/heketi-start.sh"]
