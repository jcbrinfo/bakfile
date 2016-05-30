#! /bin/bash

# Move all SSH authentification key list found in `/root/user-keys` to the
# appropriate directories.
#
# Assume each file to be named after the user that accepts the keys.
#
# Usage: `./register-ssh-keys.sh`
for key_file in /root/ssh-auth-keys/*; do
   /root/bin/move-ssh-key-file.sh "$key_file" "${key_file##*/}" || exit
done
