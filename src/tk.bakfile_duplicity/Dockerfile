# The Docker image for Duplicity.

FROM tk.bakfile_users
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

# Install GnuPG, Duplicity and dependencies of some backends (as of 0.7)
#
# Note: Even if the GnuPG executable is not listed in Duplicity’s dependencies,
# the latter will not work without the former.
RUN apt-get update && apt-get install -y \
	duplicity \
	gnupg \
	python-boto \
	python-pyrax \
	lftp

ENTRYPOINT ["/usr/bin/duplicity"]
