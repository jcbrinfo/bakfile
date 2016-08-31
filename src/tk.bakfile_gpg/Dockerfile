# The Docker image for GnuPG 2.
#
# Useful to manage the encryption keys for the backups.

FROM tk.bakfile_duplicity
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

RUN apt-get update && apt-get install -y gnupg2

ENTRYPOINT ["/usr/bin/gpg2"]
