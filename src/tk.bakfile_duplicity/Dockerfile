# The Docker image for Duplicity.

FROM tk.bakfile_users
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

# Install Duplicity and dependencies of some backends (as of 0.7)
RUN apt-get update && apt-get install -y \
	duplicity \
	python-boto \
	python-pyrax \
	lftp

ENTRYPOINT ["/usr/bin/duplicity"]
