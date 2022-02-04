package guide

import (
	"github.com/play-with-go/preguide"

	"path"
)

Delims: ["{{{", "}}}"]

FilenameComment: true

Defs: {
	_ImageTag:       *":45028dcedfccaaf9face327c7e0596c7138a38f6" | string @tag(imagetag)
	ExampleName:     "fosdem2022"
	DockerImage:     "cueexamples/\(ExampleName)"
	DockerImageTag:  "\(DockerImage)\(_ImageTag)"
	DemoRepo:        "cue-examples/\(ExampleName)"
	DemoRepoName:    path.Base(DemoRepo)
	Workdir:         "/workdir"
	WorkdirMount:    path.Base(Workdir)
	Funquoter:       "funquoter"
	Quoteserver:     "quoteserver"
	FunquoterSchema: "\(Workdir)/\(Funquoter)/schema.cue"
	RootSchema:      "\(Workdir)/schema.cue"
	Monmon:          "\(Workdir)/infra/mon/mon.cue"
	Mondir:          path.Dir(Monmon)
}

Scenarios: (Defs.ExampleName): preguide.#Scenario & {
	Description: "A practical guide to CUE: patterns for everyday use"
}

Terminals: term1: preguide.#Terminal & {
	Description: "The main terminal"
	Scenarios: (Defs.ExampleName): Image: Defs.DockerImageTag
}

Steps: cueversion: preguide.#Command & {
	Source: """
		cue version
		"""
}

Steps: goversion: preguide.#Command & {
	Source: """
		go version
		"""
}

Steps: cdworkdir: preguide.#Command & {
	Source: """
		cd \(Defs.Workdir)
		"""
}

Steps: removeoldcluster: preguide.#Command & {
	InformationOnly: true
	// We don't care if these commands fail; best efforts
	Source: """
		export LOG_COLORS=false
		export LOG_LEVEL=warn
		k3d cluster delete acme.com > /dev/null 2>&1 || true
		k3d registry delete registry.acme.com > /dev/null 2>&1 || true
		"""
}

Steps: startcluster: preguide.#Command & {
	Source: """
		k3d registry create --no-help registry.acme.com --port 5000
		k3d cluster create acme.com --registry-use k3d-registry.acme.com:5000
		"""
}

Steps: exportenv: preguide.#Command & {
	Source: """
		export KUBECONFIG="$(k3d kubeconfig write acme.com)"
		"""
}

Steps: buildimages: preguide.#Command & {
	Source: """
		docker buildx build --quiet --push -t localhost:5000/\(Defs.ExampleName)/funquoter -f funquoter/Dockerfile .
		docker buildx build --quiet --push -t localhost:5000/\(Defs.ExampleName)/quoteserver -f quoteserver/Dockerfile .
		"""
}

Steps: deleteoldpods: preguide.#Command & {
	InformationOnly: true
	Source: """
		kubectl delete -f quoteserver/kube.yaml || true
		kubectl delete -f funquoter/kube.yaml || true
		"""
}

Steps: startpods: preguide.#Command & {
	Source: """
		kubectl apply -f quoteserver/kube.yaml
		kubectl apply -f funquoter/kube.yaml
		"""
}

Steps: waitforfunquoterready: preguide.#Command & {
	InformationOnly: true
	Source: """
		while true
		do
			kubectl logs -l app=funquoter 2>&1 | grep 'Concurrency is not parallelism' && break || true
			sleep 1
		done
		"""
}

Steps: pwdroot: preguide.#Command & {
	Source: """
		pwd
		"""
}

Steps: modulelist: preguide.#Command & {
	Source: """
		go list -m
		go list ./...
		"""
}

Steps: lsfunquoterquoteserver: preguide.#Command & {
	Source: """
		ls funquoter quoteserver
		"""
}

Steps: getpods: preguide.#Command & {
	Source: """
		kubectl get pods
		"""
}

Steps: initialfunquoterlogs: preguide.#Command & {
	Source: """
		kubectl logs -l app=funquoter
		"""
}

Steps: cdfunquotervalidate: preguide.#Command & {
	Source: """
		cd funquoter
		"""
}

Steps: createfunquoterschema: preguide.#UploadFile & {
	Target: Defs.FunquoterSchema
	Path:   "./_files/funquoter/schema.cue"
}

Steps: firstvet: preguide.#Command & {
	Source: """
		cue vet schema.cue -d Object kube.yaml
		"""
}

Steps: checknothingtoapply: preguide.#Command & {
	Source: """
		kubectl apply -f kube.yaml
		"""
}

Steps: createinframonteam: preguide.#Command & {
	Source: """
		cd \(Defs.Workdir)
		mkdir -p \(Defs.Mondir)
		"""
}

Steps: inframon: preguide.#UploadFile & {
	Target: Defs.Monmon
	Path:   "./_files/infra/mon/mon.cue"
}

Steps: cuemodinit: preguide.#Command & {
	Source: """
		cue mod init acme.com/x
		"""
}

Steps: returnfunquoter: preguide.#Command & {
	Source: """
		cd funquoter
		"""
}

Steps: pullmon: preguide.#UploadFile & {
	Target: "\(Defs.Workdir)/funquoter/mon.cue"
	Path:   "./_files/funquoter/mon.cue"
}

Steps: yamlpullmodel: preguide.#Command & {
	Source: """
		cue export :kube --out yaml -d Object kube.yaml
		"""
}

Steps: rmpullmodel: preguide.#Command & {
	Source: """
		rm mon.cue
		"""
}

Steps: pushmon: preguide.#UploadFile & {
	Target: "\(Defs.Workdir)/schema.cue"
	Path:   "./_files/schema.cue"
}

Steps: yamlpushmodel: preguide.#Command & {
	Source: """
		cue export :kube --out yaml -d Object kube.yaml
		"""
}

Steps: kubetools: preguide.#UploadFile & {
	Target: "\(Defs.Workdir)/kube_tool.cue"
	Path:   "./_files/kube_tool.cue"
}

Steps: updaterootschemafortools: preguide.#UploadFile & {
	Target: "\(Defs.Workdir)/schema.cue"
	Path:   "./_files/schema_tools.cue"
}

Steps: runinitialcmdprint: preguide.#Command & {
	Source: """
		cue cmd print
		"""
}

Steps: runinitialcmdapply: preguide.#Command & {
	Source: """
		cue cmd apply
		"""
}

Steps: initialkubedefs: preguide.#UploadFile & {
	Target: "\(Defs.Workdir)/kube_defs.cue"
	Path:   "./_files/kube_defs.cue"
}

Steps: failingcuecmdapply: preguide.#Command & {
	Source: """
		! cue cmd apply
		"""
}

Steps: cuedeps: preguide.#UploadFile & {
	Target: "\(Defs.Workdir)/cue_deps.go"
	Path:   "./_files/cue_deps.go"
}

Steps: getgo: preguide.#Command & {
	Source: """
		go get k8s.io/api/apps/v1@v0.23.2
		"""
}

Steps: cuegetgo: preguide.#Command & {
	Source: """
		cue get go k8s.io/api/apps/v1
		"""
}

Steps: nowworkingapply: preguide.#Command & {
	Source: """
		cue cmd apply
		"""
}

Steps: cueimport: preguide.#Command & {
	Source: """
		cue import -p kube -l 'objByKind:' -l 'strings.ToCamel(kind)' -l metadata.name kube.yaml
		"""
}

Steps: inspectimportedcue: preguide.#Command & {
	Source: """
		cat kube.cue
		"""
}

Steps: cuetrim: preguide.#Command & {
	Source: """
		cue trim -s
		"""
}

Steps: trimmedapply: preguide.#Command & {
	Source: """
		cue cmd apply
		"""
}

Steps: noyamlapply: preguide.#Command & {
	Source: """
		rm kube.yaml
		cue cmd apply
		"""
}

Steps: tidyup: preguide.#Command & {
	InformationOnly: true
	Source: """
		k3d cluster delete acme.com > /dev/null 2>&1 || true
		k3d registry delete registry.acme.com > /dev/null 2>&1 || true
		"""
}
