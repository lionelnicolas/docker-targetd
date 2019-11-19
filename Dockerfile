FROM fedora:28

# install LVM libraries and targetd
RUN \
	yum install -y \
		lvm2 \
		targetcli \
		targetd \
		&& \
	yum clean all && \
	rm -rf /var/cache/yum

# add startup script
COPY targetd-start /usr/bin/targetd-start

# set startup command
CMD exec /usr/bin/targetd-start
