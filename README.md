# Bakfile: A Private File Server

This repository permits to build Docker images for a secure rsync server and
related utilities. Users are authenticated using SSH public keys. The goal of
this repository is to make the following tasks easier:

* Setup a secure rsync server for a [LAN](https://en.wikipedia.org/wiki/Local_area_network).
* Upgrade the server or the user list without losing data.
* Upload/download encrypted backups to/from the cloud (using Duplicity).
* Manage encryption keys.
* Sandbox everything inside Linux containers (using Docker Engine and Docker
  Compose).


## Requirements

* A POSIX system (Linux, OS X, Cygwin, Linux Subsystem for Windows…)

* Docker Engine, version 1.10 or greater

* Docker Compose, version 1.7 or greater

* Enough space in Docker’s workspace (`/var/lib/docker` on Linux) to hold the
  server and its user’s files.

* When upgrading the server or the user list, enough space in `bak` to hold a
  copy of the `/home` directory of the server.


## Files

* `bak/`: Used for exportation/importation. See the `export` and `import`
   targets of the `Makefile`.

* `src/`: Docker build contexts.

	* `docker-compose.yml`: Docker Compose configuration.

	* `tk.backfile_users/root`: Files copied in the `/root` directory of the
	  image.

		* `rsync-users`: List of the SSH users. All lines must be in the form
		  `{UID}:{userName}`. Example: `1025:somebody`. The UID should be
		  between 1025 and 29999. Empty lines are ignored.

		  **Note:** IDs between 1000 and 1024 are reserved for use by scripts in
		  this project.

		* `ssh-auth-keys/`: The initial SSH authentication keys of the users.
		  For each user, this directory must contain a file with the name of the
		  user and with the content of the wanted `~/.ssh/authorized_keys` file.

	* `tk.bakfile_rsync/sshd_config`: Used by `tk.bakfile_rsync` as the
	  `/etc/ssh/sshd_config` configuration file. If the default
	  `/etc/ssh/sshd_config` file has changed since the version(s) specified in
	  the file, you may need to update some settings.

* `Makefile`: Builds the contexts needed to build the Docker images.


## Docker images

* `tk.bakfile_users`: Base image for the other images. Creates the
  `rsync-users`  group and the users. Any image using the data of the file
   server must inherit of this service so UIDs and GIDs will be correctly set.

* `tk.bakfile_data`: Image for the data volume container. Defines
  the `/home` volume. The `Dokerfile` automatically populate the `.ssh`
  directory of the users. Any container using the data of the file server must
  be run with the `--volumes-from tk.bakfile_data` option.

* `tk.bakfile_rsync`: Installs an OpenSSH server with rsync. The entry point
  is the command of the SSH deamon. Exposes the SSH server at port 22.

* `tk.bakfile_duplicity`: Installs Duplicity and set it as the entry point.

* `tk.bakfile_gpg`: Same as `tk.bakfile_duplicity`, but with GnuPG as the entry
  point. Useful to manage the encryption keys for the backups.


## Volumes

* `home` (`/home`): User’s files, including authentication keys (as usual).

* `duplicity.cache` (`/root/.duplicity`): Duplicity’s cache.

* `/root/.backup-meta`: Files for the backup tools (like Duplicity). Mapped to
  an host’s directory while following the instructions in the “How to launch a
  Duplicity backup” section.


## If you do not use `sudo`

If you do not want to use `sudo`, specify `SUDO=` every time you run `make`.
For example, run `make SUDO= something` instead of `make something`.

**Note:** You will need the root privileges for most targets.


## Setup a firewall

Before running the rsync/ssh server, you should setup a firewall on the host to
restrict the incoming connections.


### How to setup ufw/gufw

**Note:** The “host port” is the port the users will use to connect to your
server.

1. If not already done, enable the firewall.

2. Ensure that incoming connections are denied by default.

3. Add a rule to allow incoming connections to the host port (TCP).

4. If possible, restrict the rule to connections from a specific
   [subnet](https://en.wikipedia.org/wiki/Subnetwork). This provides an
   additional protection against connections coming from outside your LAN.

5. Add a `LIMIT` rule for the host port (TCP). This will limit the rate of the
   connections that come from a same IP address.


## How to build the images

1. Fill `src/tk.backfile_users/root/rsync-users` and
   `src/tk.backfile_users/root/ssh-auth-keys/` as explained in the “Files”
   section.

2. Run `make RSYNC_PORT=<host port> install`,
   replacing `<host port>` by the port on the host that will be used to connect
   to the server. When possible, you should not use well-known ports in order to
   limit the number of connections from software that look for vulnerable
   servers.

The last step will also generate a POSIX shell script named `./compose`. This
script is a wrapper around Docker Compose that sets the values of the `-f` and
`-p` options for this project so you do not have to specify them yourself when
you run this script instead of calling Docker Compose directly.

**Note:** The `./compose` script assumes that the project directory is the
current working directory.

**Note:** Never use the `up` subcommand without specifying a service because a
lot of “services” defined in this project are not daemons.

**Note:** To regenerate `./compose` (for example, because you forgot to override
a variable of the `Makefile`), run `make clean && make`.


## How to test the SSH configuration

**Note:** The images MUST be built before doing this.

1. Run `make installcheck`.


## How to start the rsync/ssh server

**Note:** The images MUST be built before doing this.

1. Run `./compose up -d rsync`.


## How to launch a Duplicity backup

In the following instructions, `<backup meta>` refers to the directory in the
host where to put Duplicity’s cache and GnuPG data.

**Note:** Duplicity uses GnuPG to encrypt backups.

**Note:** The images **MUST** be built before doing this.

1. Ensure that `<backup meta>` contains at least a `duplicity-cache` (for
   Duplicity’s cache) and a `gnupg` (for GnuPG data) subdirectory. For each
   missing directory, create an empty directory with the required name. These
   directories should have `root:root` as the ownership and `0700` (“only the
   owner has rights”) as the permissions.

2. If not already done, generate an encryption key by running
   `./compose run -v <backup meta>:/root/.backup-meta --rm gpg --gen-key`.

   **Note:** If you forget the ID of the generated key, you may look for it by
   running
   `./compose run -v <backup meta>:/root/.backup-meta --rm gpg --list-keys`.

3. Run `./compose run -v <backup meta>:/root/.backup-meta --rm duplicity <args...>`,
   replacing `<args...>` by the arguments to pass to the `duplicity` command.

   Example:

   ```
   ./compose pause rsync && \
   ./compose run -v <backup meta>:/root/.backup-meta --rm duplicity \
       --full-if-older-than 1M --encrypt-sign-key ABCD1234 --progress /home \
       copy://user@example.com@copy.com/home-backup && \
   ./compose run -v {hostBackupMeta}:/root/.backup-meta --rm duplicity \
       remove-all-but-n-full 2 --force --encrypt-sign-key ABCD1234 \
       copy://user@example.com@copy.com/home-backup
   ```

When backuping the GnuPG data, only the following files are important:

* `<backup meta>/gnupg/secring.gpg`
* `<backup meta>/gnupg/pubring.gpg`
* `<backup meta>/gnupg/trustdb.gpg`

All other files of `{hostBackupMeta}` consist in lock files and caches.

**Note:** For the last one, only data exported by a
`gpg --homedir <backup meta>/gnupg --export-ownertrust` command is important.
For details, see `man gpg`.


## How to open a shell in the `/home` volume

**Note:** The images **MUST** be built before doing this.

1. Run `make run-data-shell`.


## How to upgrade the user list

If you want to add or remove users while keeping data held by
`tk.bakfile_data`, do the following:

1. Edit the `src/tk.backfile_users/root/ssh-users` file to reflect the desired
   user list and UIDs. For details, see the “Files” section.

   **Note:** During the following steps, `tar` will be used to export and
   reimport the `/home` volume. To restore ownership, it will try to match user
   and group names first, and fall back using the saved UID and GID. For more
   information, see documentation of the `--numeric-owner` option of GNU Tar and
   [http://serverfault.com/a/445504](http://serverfault.com/a/445504). This
   means you should not change existing names and IDs. If you do and `tar` does
   not restore ownership correctly, see the “How to change ownership in batch”
   subsection bellow.

   **Note:** Whenever possible, you should avoid re-using the names or UIDs of
   the deleted users. Better be safe than sorry. :)

2. Ensure that the `src/tk.backfile_users/root/ssh-auth-keys` directory contains
   the authentication keys of the desired users and does not contain any file
   associated to the users that will be removed. For details, see the “Files”
   section.

3. Stop (but do not remove yet) Bakfile’s containers by invoking
   `./compose stop`.

4. Run `make export`. This makes a GNU TAR of the volumes at `bak/volumes.tar`.
   Before continuing, you should double-check the archive.

5. Fully uninstall (“purge”) Bakfile. You may use `make purge` to do this.

   **WARNING:** This will delete the `/home` volume. So, again, you should be
   sure that you did the previous step correctly before doing this.

6. Run `make install`.

7. Run `make import`. This restores the content of the `home` (`/home`) and
   `duplicity.cache` (`/root/.duplicity`) volumes from the `bak/volumes.tar`
   archive.

8. For each user to remove, delete its “home” directory from `/home` using
   a shell as described in the “How to open a shell in the `/home` volume”
   section.

9. Check ownership of the imported files  by using the `tk.bakfile_data`’s
   shell. For details, see the “How to open a shell in the `/home` volume”
   section. If you get files associated to the wrong user, see the “How to
   change owners in batch” subsection bellow.

10. If everything is OK, you may run `make clean-bak` to delete everything in
    `bak/`.


### How to change ownership in batch

If someday you need to transfer ownership of all files that belong to an user to
another, here is a way to do it:

**WARNING:** Some files in `/home` come from the `tk.bakfile_users` image. You
should not edit the ownership of these files.

1. Follow the procedure described in the “How to open a shell in the `/home`
   volume” section.

2. Run `chown -R --from=<old owner>:<old group> <new owner>:<new group> -- <files…>`,
   replacing `<old owner>`, `<old group>`, `<new owner>` and `<new group>` by
   the current owner, the current group, the new owner and the new group,
   respectively. `chown` automatically excludes files that do not have the
   ownership specified with the `--from` option. For details, see `man chown`.

If you need to swap the ownership between two users, you can create a temporary
user using `adduser` before running `chown`.


## How to clean the project directory

To remove all your setting files and volume backups from the project directory,
see the `*clean` and `clean-*` targets of the `Makefile`.


## How to uninstall
To delete the Docker containers, images and volumes, see the `uninstall` and
`purge` targets of the `Makefile`.


## TODO

* Explain how to upgrade the images.
