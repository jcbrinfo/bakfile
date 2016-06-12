# Image for the data volume container.

FROM tk.bakfile_users
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

RUN mkdir -p -m 700 /root/.backup-meta \
		/root/.backup-meta/gnupg \
		/root/.backup-meta/duplicity-cache \
	&& chmod u+x /root/bin/move-ssh-key-file.sh \
	&& chmod u+x /root/bin/register-ssh-keys.sh \
	&& /bin/bash /root/bin/register-ssh-keys.sh

VOLUME /home
CMD ["/bin/true"]
