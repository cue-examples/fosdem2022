// Copyright 2021 The CUE Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package ci

import (
	"github.com/SchemaStore/schemastore/src/schemas/json"
)

workflowsDir: *"./" | string @tag(workflowsDir)

_#branchRefPrefix:   "refs/heads/"
_#mainBranch:        "main"
_#releaseTagPattern: "v*"

workflows: [...{file: string, schema: (json.#Workflow & {})}]
workflows: [
	{
		file:   "test.yml"
		schema: test
	},
]

test: _#bashWorkflow & {
	name: "Test"
	on: {
		push: {
			branches: ["main"]
			"tags-ignore": [_#releaseTagPattern]
		}
		pull_request: {}
	}

	jobs: {
		test: {
			strategy:  _#testStrategy
			"runs-on": "${{ matrix.os }}"
			steps: [
				_#dockerLogin,
				_#installQemu,
				_#installBuildx,
				_#installGo,
				_#checkoutCode,
				_#cacheGoModules,
				_#goGenerate,
				_#goTest,
				_#step & {
					// Intentionally do not skip cache for now
					// because output is not stable
					run: "./guide/gen.sh"
				},
				_#checkGitClean,
				_#step & {
					run: "./docker/build.sh"
					if:  "${{ \(_#isMain) }}"
				},
				_#step & {
					run: "./docker/build.sh -l"
					if:  "${{ \(_#isPR) }}"
				},
				_#step & {
					run: "./guide/gen.sh -l"
					if:  "${{ \(_#isPR) }}"
				},
			]
		}
	}

	// _#isMain is an expression that evaluates to true if the
	// job is running as a result of a main commit push
	_#isMain: "github.ref == '\(_#branchRefPrefix+_#mainBranch)'"

	// _#isPR is an expression that evaluates to true if the
	// job is running as a result of a PR workflow trigger
	_#isPR: "github.head_ref != ''"
}

_#bashWorkflow: json.#Workflow & {
	jobs: [string]: defaults: run: shell: "bash"
}

// TODO: drop when cuelang.org/issue/390 is fixed.
// Declare definitions for sub-schemas
_#job:  ((json.#Workflow & {}).jobs & {x: _}).x
_#step: ((_#job & {steps:                 _}).steps & [_])[0]

_#latestStableGo: "1.17.6"

_#linuxMachine:   "ubuntu-18.04"
_#macosMachine:   "macos-10.15"
_#windowsMachine: "windows-2019"

_#testStrategy: {
	"fail-fast": false
	matrix: {
		"go-version": [_#latestStableGo]
		os: [_#linuxMachine]
	}
}

_#setGoBuildTags: _#step & {
	_#tags: string
	name:   "Set go build tags"
	run:    """
		go env -w GOFLAGS=-tags=\(_#tags)
		"""
}

_#installGo: _#step & {
	name: "Install Go"
	uses: "actions/setup-go@v2"
	with: {
		"go-version": *"${{ matrix.go-version }}" | string
		stable:       false
	}
}

_#checkoutCode: _#step & {
	name: "Checkout code"
	uses: "actions/checkout@v2"
}

_#cacheGoModules: _#step & {
	name: "Cache Go modules"
	uses: "actions/cache@v2"
	with: {
		path: "~/go/pkg/mod"
		key:  "${{ runner.os }}-${{ matrix.go-version }}-go-${{ hashFiles('**/go.sum') }}"
		"restore-keys": """
			${{ runner.os }}-${{ matrix.go-version }}-go-
			"""
	}
}

_#goGenerate: _#step & {
	name: "Generate"
	run:  "go generate ./..."
}

_#goTest: _#step & {
	name: "Test"
	run:  "go test ./..."
}

_#checkGitClean: _#step & {
	name: "Check that git is clean post generate and tests"
	run:  "test -z \"$(git status --porcelain)\" || (git status; git diff; false)"
}

_#dockerLogin: {
	name: "Docker login"
	uses: "docker/login-action@v1"
	with: {
		username: "cueexamples"
		password: "${{ secrets.DOCKER_HUB_TOKEN }}"
	}
}

_#installQemu: {
	name: "Install qemu"
	uses: "docker/setup-qemu-action@v1"
}

_#installBuildx: {
	name: "Setup buildx"
	uses: "docker/setup-buildx-action@v1"
}
