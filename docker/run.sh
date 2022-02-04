#!/usr/bin/env bash

set -eu

# Change to the root of the repository that contains this script
command cd "$( command cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/"
source "gen_shell_vars.bash"
command cd "$(git rev-parse --show-toplevel)"


if [ -d workdir ]
then
	echo "$PWD/workdir already exists; not creating"
else
	cp -rp guide/_skel workdir
fi

os=$(uname|tr '[:upper:]' '[:lower:]')
dockersock=/var/run/docker.sock
if [ "$os" == "darwin" ]
then
	dockersock=/var/run/docker.sock.raw
fi

docker run --net host --rm -it -e USERINFO="$(id)" -v $PWD/workdir:/workdir -v $dockersock:/var/run/docker.sock $DOCKER_IMAGE_TAG bash
