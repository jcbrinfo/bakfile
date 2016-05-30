#! /bin/bash

# Creates all rsync users found in `/root/rsync-users`.
#
# Each non-empty line of the `/root/rsync-users` file contains a user to add in
# the `{UID}:{userName}` format.
#
# Usage: `./add-rsync-users.sh`
while read u; do
	# Skip empty lines.
	if [ "${#u}" != 0 ]; then
		IFS=':' read -a user_array <<< "$u" || exit
		if [ "${#user_array[@]}" != 2 ]; then
			echo "$0"': Unexpected user entry `'"$u"'`.' \
				'Expected format: `{UID}:{userName}`.' 1>&2
			exit 1
		fi
	  	/root/bin/add-rsync-user.sh "${user_array[0]}" "${user_array[1]}" || exit
	fi
done < /root/rsync-users
