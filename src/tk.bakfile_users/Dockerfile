# Base image for the other images.
#
# Creates the `rsync-users` group and the users. Any image using the data of the
# file server must inherit of this service so UIDs and GIDs will be correctly
# set.

FROM debian:stretch
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

COPY root /root/

# We must explicitly invoke bash/sh because chmoding and executing the same
# file in one command may trigger a “text file busy” error and we want to
# support hosts with a filesystem that ignores POSIX permissions (e.g. NTFS,
# FAT, etc.).
RUN mkdir -p -m 700 -- \
		/root/.gnupg \
		/root/.cache/duplicity \
	&& addgroup --gid 1000 rsync-users \
	&& bash /root/bin/add-rsync-users.sh \
	&& sh   /root/bin/register-ssh-keys.sh

CMD ["/bin/true"]
