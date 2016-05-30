#! /bin/sh

# Creates the specified rsync user.
#
# Usage: `./add-rsync-user.sh {uid} {userName}`
adduser --disabled-password --gecos "" --uid "$1" "$2" \
&& adduser "$2" rsync-users
