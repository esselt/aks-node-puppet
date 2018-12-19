#!/bin/sh
set -e

# no arguments passed
# or first arg is `-f` or `--some-option`
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]
then
	# add our default arguments
	set -- dockerd \
		--host=unix:///var/run/docker.sock \
		--host=tcp://0.0.0.0:2375 \
		"$@"
fi

if [ "$1" = 'dockerd' ]
then
	# if we're running Docker, let's pipe through dind
	# (and we'll run dind explicitly with "sh" since its shebang is /bin/bash)
	set -- sh "$(which dind)" "$@"

	# explicitly remove Docker's default PID file to ensure that it can start properly if it was stopped uncleanly (and thus didn't clean up the PID file)
	find /run /var/run -iname 'docker*.pid' -delete
fi

if [ "$1" = 'bash' ]
then
	exec "$@"
fi

# start docker daemon before running command
nohup dockerd \
		--host=unix:///var/run/docker.sock \
		--host=tcp://0.0.0.0:2375 \
		> /dev/null 2>&1 &
echo -n "Starting docker daemon"
while (! docker stats --no-stream > /dev/null 2>&1)
do
    echo -n "."
    sleep 0.2
done
echo

docker load -i /usr/local/bin/alpine3.8.tar

exec "$@"