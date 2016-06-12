# Same as `tk.bakfile.duplicity`, but with GnuPG as the entry point.
#
# Useful to manage the encryption keys for the backups.

FROM tk.bakfile_duplicity
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

ENTRYPOINT ["/usr/bin/gpg", "--homedir", "/root/.backup-meta/gnupg"]
