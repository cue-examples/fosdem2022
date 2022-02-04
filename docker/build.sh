#!/usr/bin/env bash

set -eu

# cd to the root of the repo
command cd "$( command cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "gen_shell_vars.bash"
cd $(git rev-parse --show-toplevel)

# build.sh
#
# With no arguments, builds for all target platforms. Furthermore,
# if the build is happening on CI on the main branch, then build
# will be tagged according to the commit and pushed to docker hub
#
# The -l flag instead loads the build result into Docker, available
# for immediate use.

linuxarm64="linux/arm64"
linuxamd64="linux/amd64"

# Default to all platforms
platform="$linuxamd64,$linuxarm64"

loadorpush=""
while getopts ":l" opt; do
	case $opt in
		l)
			arch=$(uname -m)
			case $arch in
				aarch64)
					platform="$linuxarm64"
					;;
				x86_64)
					platform="$linuxamd64"
					;;
				\?)
					echo "unsuported arch $arch" >&2
					exit 1
					;;
			esac
			loadorpush=--load
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done
shift $((OPTIND-1))

# Are we building on CI on main?
tag=""
if [ "${CI:-}" == "true" ] && [ "${GITHUB_REF:-}" == "refs/heads/main" ]
then
	loadorpush=--push
	tag=":$GITHUB_SHA"
fi

# change to docker for the build
cd docker

docker buildx build -t $DOCKER_IMAGE$tag $loadorpush --platform $platform .
