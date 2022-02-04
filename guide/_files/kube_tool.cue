package kube

import (
	"strings"
	"encoding/yaml"
	"encoding/json"

	"tool/file"
	"tool/cli"
	"tool/exec"
)

// -- Global tasks

// glob matches the YAML files in the current directory.
globYAML: file.Glob & {
	glob: "*.yaml"
}

open: {
	for _, f in globYAML.files {
		(f): file.Read & {
			filename: f

			contents: _
			data:     yaml.UnmarshalStream(contents)
		}
	}
}

// allTasks lists all tasks run to fetch the configuration. Other tasks
//
allTasks: {glob: globYAML, open}

// -- Linking results into schema

// Put results into the object map as defined in our top-level schema.
objByKind: {
	for v in open for obj in v.data {
		(strings.ToLower(obj.kind)): (obj.metadata.name): obj
	}
}

// allObjects is a list of all Kubernetes objects declared in CUE and YAML
// files.
allObjects: [ for objs in objByKind for obj in objs {obj}]

// -- Commands

// Ensure that commands run after the global tasks.
// TODO: flow should handle this automatically. It currently does not handle
// the indirection of references through global definitions correctly.
command: [string]: $after: allTasks

// print prints all Kubernetes objects as a stream of marshalled JSON.
command: print: cli.Print & {
	text: json.MarshalStream(allObjects)
}

// apply sends the k8s objects off to kubectl.
command: apply: exec.Run & {
	cmd:   "kubectl apply -f -"
	stdin: yaml.MarshalStream(allObjects)
}
