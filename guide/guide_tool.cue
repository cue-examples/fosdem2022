package guide

import "tool/file"

command: genshellvars: file.Create & {
	filename: "../docker/gen_shell_vars.bash"
	contents: """
	DOCKER_IMAGE="\(Defs.DockerImage)"
	DOCKER_IMAGE_TAG="\(Defs.DockerImageTag)"
	"""
}
