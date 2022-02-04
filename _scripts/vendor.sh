#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

go mod download

# Change to the root of the repository that contains this script
command cd "$( command cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/"
command cd "$(git rev-parse --show-toplevel)"

for i in "$@"
do
	go mod download $i
	dir=$(go list -m -f={{.Dir}} $i)
	mkdir -p ./cue.mod/pkg/$i
	(command cd $dir && find -type d -name internal -prune -o -type d -name cue.mod -prune -o -iname "*_tool.cue" -prune -o -type f -iname "*.cue" -print) | rsync -a --delete --chmod=Du+w,Fu+w --files-from=- $dir ./cue.mod/pkg/$i
done

go mod tidy
