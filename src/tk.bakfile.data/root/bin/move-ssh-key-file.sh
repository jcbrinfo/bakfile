#! /bin/sh

# Moves `{sshKeysPath}` to `/home/{userName}/.ssh/authorized_keys`.
#
# Usage: `./move-ssh-key-file.sh {sshKeysPath} {userName}`
mkdir -p -m 700 "/home/$2/.ssh" \
&& chmod 600 "$1" \
&& mv -T "$1" "/home/$2/.ssh/authorized_keys" \
&& chown "$2:$2" "/home/$2/.ssh" "/home/$2/.ssh/authorized_keys"
