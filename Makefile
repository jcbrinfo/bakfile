# See `README` and below.

.POSIX:
.SUFFIXES:
SHELL = /bin/sh


# ##############################################################################
# Macros

# The following macros MUST NOT contain apostrophes in order to workaround
# the lack of a “substring substitution” feature in POSIX make:
#
# * COMPOSE_FILE
# * DOCKER_COMPOSE
# * DOCKER_COMPOSE_PROJECT
# * PROJECT_NAME
# * srcdir
# * SUDO

srcdir = ./src

# Path to the backup directory on the host (`export` and `import`).
bakdir = ./bak

# Name of the Docker Compose project.
PROJECT_NAME = tk.bakfile

USERS_SERVICE = users
SHELL_SERVICE = bash
RSYNC_SERVICE = rsync
TAR_SERVICE = tar

# Path to the Docker Compose configuration.
COMPOSE_FILE = $(srcdir)/docker-compose.yml

# Path to the POSIX Shell script that wraps Docker Compose with the right
# options for this project.
COMPOSE_RUNNER = ./compose

# Absolute path to the directory in the host where to put GnuPG data.
#
# You MUST specify the value of this variable when running the `install` target.
GNUPG_HOMEDIR = /dev/null

# Port of the rsync sever on the host.
#
# You SHOULD specify the value of this variable when running the `install`
# target.
#
# Whenever possible, you SHOULD not use well-known ports in order to limit the
# number of connections from software that look for vulnerable servers.
RSYNC_PORT = 22

# Name of the archive in `bak/` (`export` and `import`).
VOLUME_TAR = volumes.tar

# Volumes to export/import (`export` and `import`). Use absolute paths.
VOLUMES = /home /root/.duplicity

# Temporary path for the backup directory on the container (`export` and
# `import`).
CONTAINER_BAK_DIRECTORY = /bak

SUDO = sudo
DOCKER = $(SUDO) docker
DOCKER_COMPOSE = $(SUDO) docker-compose
DOCKER_COMPOSE_PROJECT = $(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT_NAME)
DOCKER_TAR = $(DOCKER_COMPOSE_PROJECT) run --rm -- $(TAR_SERVICE)


# ##############################################################################
# Targets

.PHONY: all
all: $(COMPOSE_RUNNER)
	# To build Docker images, run `$(MAKE) install`.

# Builds a POSIX Shell script that wraps Docker Compose with the right options
# for this project.
$(COMPOSE_RUNNER):
	echo '#! /bin/sh' > $(COMPOSE_RUNNER)
	echo '# Runs Docker Compose with the right options for this project.' >> $(COMPOSE_RUNNER)
	echo '#' >> $(COMPOSE_RUNNER)
	echo '# Assumes that the project directory is the current directory.' >> $(COMPOSE_RUNNER)
	printf '%s "$$@"\n' '$(DOCKER_COMPOSE_PROJECT)' >> $(COMPOSE_RUNNER)
	chmod u+x -- $(COMPOSE_RUNNER)

# Builds the Docker images.
.PHONY: install
install: all
	mkdir -p -- $(bakdir)
	BAKFILE_RSYNC_PORT=$(RSYNC_PORT) BAKFILE_GNUPG_HOMEDIR=$(GNUPG_HOMEDIR) $(DOCKER_COMPOSE_PROJECT) build

# Remove `bak`, the user list and default users’ keys.
.PHONY: distclean maintainer-clean
distclean maintainer-clean: clean clean-bak clean-settings

# Remove the user list and default users’ keys.
.PHONY: clean-settings
clean-settings:
	rm -rf -- $(srcdir)/$(USERS_IMAGE)/root/ssh-auth-keys $(srcdir)/$(USERS_IMAGE)/root/rsync-users

# Removes the files in `bak`.
.PHONY: clean-bak
clean-bak:
	rm -rf -- $(bakdir)

.PHONY: clean mostlyclean
clean mostlyclean:
	rm -f -- $(COMPOSE_RUNNER)


# Stops containers, then removes all containers and images related to
# this project.
#
# See also: `purge`
.PHONY: uninstall
uninstall:
	$(DOCKER_COMPOSE_PROJECT) down --rmi all


# Stops containers, then removes all containers, images and **volumes** related
# to this project.
#
# WARNING: Since this target will delete the `/home` volume, `make export`
# should be run first. It also a good idea to double-check the archive generated
# by `make export`.
#
# See also: `uninstall`
.PHONY: purge
purge:
	@{ \
		printf 'This will remove all the related volume(s). Are you sure to proceed? [y/N]: ' \
		&& read response \
		&& printf '%s\n' "$${response}" | grep -Eq "$$(locale yesexpr)"; \
	} || { echo 'Aborting.' && exit 1; }
	$(DOCKER_COMPOSE_PROJECT) down --rmi all --volumes

# Runs `sshd -t` in the `rsync` image.
.PHONY: installcheck
installcheck:
	$(DOCKER_COMPOSE_PROJECT) run --rm -- $(RSYNC_SERVICE) -t

# Runs `bash` in the `tk.bakfile_data` image.
.PHONY: run-data-shell
run-data-shell:
	$(DOCKER_COMPOSE_PROJECT) run --rm -w /home -- $(SHELL_SERVICE)

# Exports `/home` as `bak/volumes.tar`.
#
# WARNING: This overwrite files without asking.
.PHONY: export
export:
	mkdir -p -- $(bakdir)
	$(DOCKER_TAR) -cf $(CONTAINER_BAK_DIRECTORY)/$(VOLUME_TAR) --atime-preserve -- $(VOLUMES)

# Imports `/home` from `bak/volumes.tar`.
#
# WARNING: This overwrite files without asking.
.PHONY: import
import:
	mkdir -p -- $(bakdir)
	$(DOCKER_TAR) -xpf $(CONTAINER_BAK_DIRECTORY)/$(VOLUME_TAR) -C / --atime-preserve --overwrite
