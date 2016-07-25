# Base image for the other images.
#
# Creates the `rsync-users` group and the users. Any image using the data of the
# file server must inherit of this service so UIDs and GIDs will be correctly
# set.

FROM debian:jessie
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

COPY root /root/

RUN mkdir -p -m 700 -- \
		/root/.gnupg \
		/root/.duplicity \
	&& addgroup --gid 1000 rsync-users \
	&& chmod u+x /root/bin/add-rsync-users.sh \
	&& chmod u+x /root/bin/register-ssh-keys.sh \
	&& /root/bin/add-rsync-users.sh \
	&& /root/bin/register-ssh-keys.sh

CMD ["/bin/true"]
