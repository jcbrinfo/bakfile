# The rsync (SSH) server.

FROM tk.bakfile_users
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

# Install software.
RUN apt-get update && apt-get install -y \
	openssh-server \
	rsync

# Avoid the “Missing privilege separation directory: /var/run/sshd” error.
RUN mkdir -m 0755 /var/run/sshd

# Configure SSH.
COPY sshd_config /etc/ssh/sshd_config

# Render auditing capabilities optional.
# See https://docs.docker.com/examples/running_ssh_service/.
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
# Because it is the role of Docker to deamonize the process, we pass the `-D`
# option to avoid `sshd` to “fork off and die” by itself.
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
