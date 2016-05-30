# The Docker image for Duplicity.

FROM tk.bakfile.users
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

# Install Duplicity, version >= 0.7.
#
# TODO: Avoid using Debian Testing as soon as possible.
COPY apt/ /etc/apt/
RUN apt-get update && apt-get install -y \
	duplicity/testing

# Make Duplicity use keys from the `/root/.backup-meta` volume.
RUN mkdir -m 0700 -p /root/.bakup-meta/gnupg && \
	ln -s -T /root/.backup-meta/gnupg /root/.gnupg

ENTRYPOINT ["/usr/bin/duplicity", "--archive-dir", "/root/.backup-meta/duplicity-cache"]
