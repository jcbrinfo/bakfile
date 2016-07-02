# See `README` and below.

.POSIX:
.SUFFIXES:
SHELL = /bin/sh

srcdir = ./src

# Path of the backup directory on the host (`export` and `import`).
bakdir = ./bak

# The name of Docker images, in the order they have to be generated.
IMAGES = tk.bakfile_users tk.bakfile_data tk.bakfile_rsync tk.bakfile_duplicity tk.bakfile_gpg

USERS_IMAGE = tk.bakfile_users
DATA_IMAGE = tk.bakfile_data
RSYNC_IMAGE = tk.bakfile_rsync

# Name of the archive in `bak/` (`export` and `import`).
VOLUME_TAR = volumes.tar

# Volumes to export/import (`export` and `import`). Use absolute paths.
VOLUMES = /home

# Temporary path for the backup directory on the container (`export` and
# `import`).
CONTAINER_BAK_DIRECTORY = /bak

DOCKER = sudo docker
DOCKER_TAR = $(DOCKER) run --rm --volumes-from=$(DATA_IMAGE) --volume="$$(cd $(bakdir) && pwd)":$(CONTAINER_BAK_DIRECTORY) $(DATA_IMAGE) /bin/tar


all:
	# Nothing to compile. To build Docker images, run `$(MAKE) images` or
	# `$(MAKE) install`.

# Builds the Docker images.
.PHONY: images install
images install:
	for i in $(IMAGES); do printf '\n%s\n' "$$i:"; $(DOCKER) build -t "$$i" "$(srcdir)/$$i" || exit; done

# Remove `bak`, the user list and default users’ keys.
.PHONY: distclean mostlyclean maintainer-clean
distclean mostlyclean maintainer-clean: clean-bak clean-settings

# Remove the user list and default users’ keys.
.PHONY: clean-settings
clean-settings:
	rm -rf $(srcdir)/$(USERS_IMAGE)/root/ssh-auth-keys $(srcdir)/$(USERS_IMAGE)/root/rsync-users

# Removes the files in `bak`.
.PHONY: clean-bak
clean-bak:
	rm -rf $(bakdir)

.PHONY: clean
clean:
	# This project does not contain generated files.

# Remove `tk.bakfile.*` Docker images.
#
# Does not remove intermediate images and dependencies.
#
# Before doing that, deletes any stopped container (volumes included) that has
# the same name than a Docker image generated by this `Makefile`.
#
# WARNING: Since this target should delete the `/home` volume, `make export`
# should be run first. It also a good idea to double-check the archive generated
# by `make export`.
.PHONY: uninstall
uninstall: uninstall-ps
	$(DOCKER) rmi $(IMAGES)
	# Intermediate images and dependencies was not removed.


# Deletes any stopped container (volumes included) that has the same name than
# a Docker image generated by this `Makefile`.
#
# WARNING: Since this target should delete the `/home` volume, `make export`
# should be run first. It also a good idea to double-check the archive generated
# by `make export`.
.PHONY: uninstall-ps
uninstall-ps:
	$(PRE_UNINSTALL)     # Pre-uninstall commands follow.
	@{ \
		printf 'This should delete your `/home` volume. Proceed? [y/N]: ' \
		&& read response \
		&& printf '%s\n' "$${response}" | grep -Eq "$$(locale yesexpr)"; \
	} || { echo 'Aborting.' && exit 1; }
	$(DOCKER) rm -v $(IMAGES)

# Creates a container for `tk.bakfile.data`.
.PHONY: run-data
run-data:
	$(DOCKER) run --name=$(DATA_IMAGE) $(DATA_IMAGE)

# Runs `bash` in the `tk.bakfile.data` image.
.PHONY: debug-data
debug-data:
	$(DOCKER) run -ti -w /home --rm --volumes-from=$(DATA_IMAGE) $(DATA_IMAGE) /bin/bash

# Runs `sshd -t` in the `tk.bakfile.rsync` image.
.PHONY: test-rsync
test-rsync:
	$(DOCKER) run --rm --volumes-from=$(DATA_IMAGE) $(RSYNC_IMAGE) -t

# Exports `/home` as `bak/volumes.tar`.
.PHONY: export
export:
	mkdir -p $(bakdir)
	$(DOCKER_TAR) -cf $(CONTAINER_BAK_DIRECTORY)/$(VOLUME_TAR) --atime-preserve -- $(VOLUMES)

# Imports `/home` from `bak/volumes.tar`.
#
# Assumes that the `tk.bakfile.data` container exists.
#
# WARNING: This overwrite files without asking.
.PHONY: import
import:
	mkdir -p $(bakdir)
	$(DOCKER_TAR) -xpf $(CONTAINER_BAK_DIRECTORY)/$(VOLUME_TAR) -C / --atime-preserve --overwrite
