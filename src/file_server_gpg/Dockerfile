# Same as `file_server_duplicity`, but with GnuPG as the entry point.
#
# Useful to manage the encryption keys for the backups.

FROM file_server_duplicity
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

ENTRYPOINT ["/usr/bin/gpg", "--homedir", "/root/.backup-meta/gnupg"]
