#! /bin/sh

# Move all SSH authentification key list found in `/root/user-keys` to the
# appropriate directories.
#
# Assume each file to be named after the user that accepts the keys.
#
# Usage: `./register-ssh-keys.sh`

set -e

# Moves `<SSH keys path>` to `/home/{user name}/.ssh/authorized_keys`.
#
# Usage: `move_key_file {SSH keys path} {user name}`
move_key_file() {
	mkdir -p -m 700 "/home/$2/.ssh"
	chmod 600 "$1"
	mv -T "$1" "/home/$2/.ssh/authorized_keys"
	chown "$2:$2" "/home/$2/.ssh" "/home/$2/.ssh/authorized_keys"
}

for key_file in /root/ssh-auth-keys/*; do
   move_key_file "$key_file" "${key_file##*/}"
done
