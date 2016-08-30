# The Docker image for Duplicity.

FROM tk.bakfile_users
MAINTAINER jcbrinfo <jcbrinfo@users.noreply.github.com>

RUN apt-get update && apt-get install -y duplicity

ENTRYPOINT ["/usr/bin/duplicity"]
