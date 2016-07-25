# The Docker image for Duplicity.

FROM tk.bakfile_users
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

# Install Duplicity, version >= 0.7.
#
# TODO: Avoid using Debian Testing as soon as possible.
COPY apt/ /etc/apt/
RUN apt-get update && apt-get install -y \
	duplicity/testing

ENTRYPOINT ["/usr/bin/duplicity"]
