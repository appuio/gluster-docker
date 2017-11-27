FROM centos:7

LABEL architecture="x86_64"
LABEL io.k8s.display-name="GlusterFS 3.12"
LABEL io.k8s.description="Gluster Community Image"
LABEL io.openshift.tags="cns,gluster"

ENV container docker

ADD *.repo /etc/yum.repos.d/

# yum update
RUN  yum --nogpgcheck -y update; yum clean all;

# To avoid the warnings while accessing the container
RUN sed -i "s/LANG/\#LANG/g" /etc/locale.conf

VOLUME [ "/sys/fs/cgroup/" ]

RUN yum -y install --nogpgcheck ntp glusterfs-server gluster-block nfs-utils attr iputils iproute glusterfs-geo-replication openssh-server openssh-clients cronie tar rsync sos sudo xfsprogs; yum clean all;

RUN sed -i '/Port 22/c\Port 2222' /etc/ssh/sshd_config

RUN sed -i 's/Requires\=rpcbind\.service//g' /usr/lib/systemd/system/glusterd.service

RUN sed -i 's/rpcbind\.service/gluster-setup\.service/g' /usr/lib/systemd/system/glusterd.service

RUN sed -i 's/rpcbind\.service//g' /usr/lib/systemd/system/gluster-blockd.service

RUN sed -i 's/ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", ENV{SYSTEMD_READY}="0"/ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", GOTO="systemd_end"/g' /usr/lib/udev/rules.d/99-systemd.rules

# Backing up gluster config as it overlaps when bind mounting.
RUN mkdir -p /etc/glusterfs_bkp /var/lib/glusterd_bkp /var/log/glusterfs_bkp;\
cp -r /etc/glusterfs/* /etc/glusterfs_bkp;\
cp -r /var/lib/glusterd/* /var/lib/glusterd_bkp;\
cp -r /var/log/glusterfs/* /var/log/glusterfs_bkp;

# Adding script to move the glusterfs config file to location
ADD gluster-setup.service /etc/systemd/system/gluster-setup.service
RUN chmod 644 /etc/systemd/system/gluster-setup.service

# Adding script to move the glusterfs config file to location
ADD gluster-setup.sh /usr/sbin/gluster-setup.sh
RUN chmod 500 /usr/sbin/gluster-setup.sh
RUN ln -s /usr/sbin/gluster-setup.sh /usr/sbin/setup.sh

# Adding script configure brick multiplexing in gluster
ADD gluster-brickmultiplex.service /etc/systemd/system/gluster-brickmultiplex.service
RUN chmod 644 /etc/systemd/system/gluster-brickmultiplex.service

# Adding script configure brick multiplexing in gluster
ADD gluster-brickmultiplex.sh /usr/sbin/gluster-brickmultiplex.sh
RUN chmod 500 /usr/sbin/gluster-brickmultiplex.sh

COPY update-params.sh /usr/local/bin/update-params.sh
RUN chmod +x /usr/local/bin/update-params.sh

# env. parameters for tcmu-runner systemd script
COPY etc/sysconfig/tcmu-runner-params /etc/sysconfig/tcmu-runner-params

RUN systemctl mask getty.target
RUN systemctl disable systemd-udev-trigger.service
RUN systemctl disable systemd-udevd.service
RUN systemctl disable nfs-server.service
RUN systemctl enable sshd.service
RUN systemctl enable ntpd.service
RUN systemctl enable gluster-setup.service
RUN systemctl enable gluster-blockd.service
RUN systemctl enable gluster-brickmultiplex.service
RUN systemctl enable glusterd.service

EXPOSE 2222 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

ENTRYPOINT ["/usr/local/bin/update-params.sh"]
CMD ["/usr/sbin/init"]

