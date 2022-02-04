#!/usr/bin/env bash

set -eu

# Change to the root of the repo that contains this script
command cd "$( command cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/"
command cd "$(git rev-parse --show-toplevel)"

rm -rf workdir
cp -rp guide/_skel workdir

# export PREGUIDE_SKIP_CACHE=true
export PREGUIDE_PROGRESS=true
# export PREGUIDE_DEBUG=true

os=$(uname|tr '[:upper:]' '[:lower:]')
dockersock=/var/run/docker.sock
if [ "$os" == "darwin" ]
then
	dockersock=/var/run/docker.sock.raw
fi

localimage=""
while getopts ":l" opt; do
	case $opt in
		l)
			localimage="-t imagetag="
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done
shift $((OPTIND-1))

go run github.com/play-with-go/preguide/cmd/preguide gen -pull=missing $localimage -mode github -runargs "term1=-e GOMODCACHE=/gomodcache -v $(go env GOMODCACHE):/gomodcache -v $dockersock:/var/run/docker.sock -v $PWD/workdir:/workdir -e \"USERINFO=$(id)\" --net host" ./guide
