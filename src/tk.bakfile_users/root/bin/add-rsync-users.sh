#! /bin/bash

# Creates all rsync users found in `/root/rsync-users`.
#
# Each non-empty line of the `/root/rsync-users` file contains a user to add in
# the `<UID>:<user name>` format.
#
# Usage: `./add-rsync-users.sh`

set -e

##
# Creates the specified rsync user.
#
# Usage: `add_rsync_user <UID> <user name>`
add_rsync_user() {
	adduser --disabled-password --gecos "" --uid "$1" "$2"
	adduser "$2" rsync-users
}

while read u; do
	# Skip empty lines.
	if [ "${#u}" != 0 ]; then
		IFS=':' read -a user_array <<< "$u"
		if [ "${#user_array[@]}" != 2 ]; then
			echo "$0"': Unexpected user entry `'"$u"'`.' \
				'Expected format: `<UID>:<user name>`.' >&2
			exit 1
		fi
		add_rsync_user "${user_array[0]}" "${user_array[1]}"
	fi
done < /root/rsync-users
