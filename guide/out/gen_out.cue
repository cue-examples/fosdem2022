package out

Terminals: [{
	Name:        "term1"
	Description: "The main terminal"
	Scenarios: {
		fosdem2022: {
			Image: "cueexamples/fosdem2022:45028dcedfccaaf9face327c7e0596c7138a38f6"
		}
	}
}]
Scenarios: [{
	Name:        "fosdem2022"
	Description: "A practical guide to CUE: patterns for everyday use"
}]
Networks: []
Env: []
FilenameComment: true
Steps: {
	cueversion: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "cueversion"
		Order:           0
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "cue version"
			ExitCode: 0
			Output: """
				cue version v0.4.2 linux/arm64

				"""
			ComparisonOutput: """
				cue version v0.4.2 linux/arm64

				"""
		}]
	}
	goversion: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "goversion"
		Order:           1
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "go version"
			ExitCode: 0
			Output: """
				go version go1.17.6 linux/arm64

				"""
			ComparisonOutput: """
				go version go1.17.6 linux/arm64

				"""
		}]
	}
	cdworkdir: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "cdworkdir"
		Order:           2
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "cd /workdir"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	removeoldcluster: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: true
		Name:            "removeoldcluster"
		Order:           3
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "export LOG_COLORS=false"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}, {
			Negated:          false
			CmdStr:           "export LOG_LEVEL=warn"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}, {
			Negated:          false
			CmdStr:           "k3d cluster delete acme.com >/dev/null 2>&1 || true"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}, {
			Negated:          false
			CmdStr:           "k3d registry delete registry.acme.com >/dev/null 2>&1 || true"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	startcluster: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "startcluster"
		Order:           4
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "k3d registry create --no-help registry.acme.com --port 5000"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}, {
			Negated:  false
			CmdStr:   "k3d cluster create acme.com --registry-use k3d-registry.acme.com:5000"
			ExitCode: 0
			Output: """
				kubectl cluster-info

				"""
			ComparisonOutput: """
				kubectl cluster-info

				"""
		}]
	}
	exportenv: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "exportenv"
		Order:           5
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "export KUBECONFIG=\"$(k3d kubeconfig write acme.com)\""
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	buildimages: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "buildimages"
		Order:           6
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "docker buildx build --quiet --push -t localhost:5000/fosdem2022/funquoter -f funquoter/Dockerfile ."
			ExitCode: 0
			Output: """
				sha256:bba8c540db5466f7a2bc1b6231cf23a59ea9cb89caf979f9aec3e56f93fafc21

				"""
			ComparisonOutput: """
				sha256:bba8c540db5466f7a2bc1b6231cf23a59ea9cb89caf979f9aec3e56f93fafc21

				"""
		}, {
			Negated:  false
			CmdStr:   "docker buildx build --quiet --push -t localhost:5000/fosdem2022/quoteserver -f quoteserver/Dockerfile ."
			ExitCode: 0
			Output: """
				sha256:c7b6b5f2a433f5f869a8457bd547b7fa3e79442bb0b3049c6715dec8ad65608f

				"""
			ComparisonOutput: """
				sha256:c7b6b5f2a433f5f869a8457bd547b7fa3e79442bb0b3049c6715dec8ad65608f

				"""
		}]
	}
	deleteoldpods: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: true
		Name:            "deleteoldpods"
		Order:           7
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "kubectl delete -f quoteserver/kube.yaml || true"
			ExitCode: 0
			Output: """
				Error from server (NotFound): error when deleting "quoteserver/kube.yaml": services "quoteserver" not found
				Error from server (NotFound): error when deleting "quoteserver/kube.yaml": deployments.apps "quoteserver" not found

				"""
			ComparisonOutput: """
				Error from server (NotFound): error when deleting "quoteserver/kube.yaml": services "quoteserver" not found
				Error from server (NotFound): error when deleting "quoteserver/kube.yaml": deployments.apps "quoteserver" not found

				"""
		}, {
			Negated:  false
			CmdStr:   "kubectl delete -f funquoter/kube.yaml || true"
			ExitCode: 0
			Output: """
				Error from server (NotFound): error when deleting "funquoter/kube.yaml": services "funquoter" not found
				Error from server (NotFound): error when deleting "funquoter/kube.yaml": deployments.apps "funquoter" not found

				"""
			ComparisonOutput: """
				Error from server (NotFound): error when deleting "funquoter/kube.yaml": services "funquoter" not found
				Error from server (NotFound): error when deleting "funquoter/kube.yaml": deployments.apps "funquoter" not found

				"""
		}]
	}
	startpods: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "startpods"
		Order:           8
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "kubectl apply -f quoteserver/kube.yaml"
			ExitCode: 0
			Output: """
				service/quoteserver created
				deployment.apps/quoteserver created

				"""
			ComparisonOutput: """
				service/quoteserver created
				deployment.apps/quoteserver created

				"""
		}, {
			Negated:  false
			CmdStr:   "kubectl apply -f funquoter/kube.yaml"
			ExitCode: 0
			Output: """
				service/funquoter created
				deployment.apps/funquoter created

				"""
			ComparisonOutput: """
				service/funquoter created
				deployment.apps/funquoter created

				"""
		}]
	}
	waitforfunquoterready: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: true
		Name:            "waitforfunquoterready"
		Order:           9
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "while true; do kubectl logs -l app=funquoter 2>&1 | grep 'Concurrency is not parallelism' && break || true; sleep 1; done"
			ExitCode: 0
			Output: """
				quotes: ["Concurrency is not parallelism."]

				"""
			ComparisonOutput: """
				quotes: ["Concurrency is not parallelism."]

				"""
		}]
	}
	pwdroot: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "pwdroot"
		Order:           10
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "pwd"
			ExitCode: 0
			Output: """
				/workdir

				"""
			ComparisonOutput: """
				/workdir

				"""
		}]
	}
	modulelist: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "modulelist"
		Order:           11
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "go list -m"
			ExitCode: 0
			Output: """
				acme.com/x

				"""
			ComparisonOutput: """
				acme.com/x

				"""
		}, {
			Negated:  false
			CmdStr:   "go list ./..."
			ExitCode: 0
			Output: """
				acme.com/x/funquoter
				acme.com/x/quote
				acme.com/x/quoteserver

				"""
			ComparisonOutput: """
				acme.com/x/funquoter
				acme.com/x/quote
				acme.com/x/quoteserver

				"""
		}]
	}
	lsfunquoterquoteserver: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "lsfunquoterquoteserver"
		Order:           12
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "ls funquoter quoteserver"
			ExitCode: 0
			Output: """
				funquoter:
				Dockerfile  kube.yaml  main.go

				quoteserver:
				Dockerfile  kube.yaml  main.go

				"""
			ComparisonOutput: """
				funquoter:
				Dockerfile  kube.yaml  main.go

				quoteserver:
				Dockerfile  kube.yaml  main.go

				"""
		}]
	}
	getpods: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "getpods"
		Order:           13
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "kubectl get pods"
			ExitCode: 0
			Output: """
				NAME                          READY   STATUS    RESTARTS   AGE
				quoteserver-f86b5b747-424lz   1/1     Running   0          32s
				funquoter-7c64784df6-lgzbt    1/1     Running   0          32s

				"""
			ComparisonOutput: """
				NAME                          READY   STATUS    RESTARTS   AGE
				quoteserver-f86b5b747-424lz   1/1     Running   0          32s
				funquoter-7c64784df6-lgzbt    1/1     Running   0          32s

				"""
		}]
	}
	initialfunquoterlogs: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "initialfunquoterlogs"
		Order:           14
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "kubectl logs -l app=funquoter"
			ExitCode: 0
			Output: """
				in funquoter
				quotes: ["Concurrency is not parallelism."]

				"""
			ComparisonOutput: """
				in funquoter
				quotes: ["Concurrency is not parallelism."]

				"""
		}]
	}
	cdfunquotervalidate: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "cdfunquotervalidate"
		Order:           15
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "cd funquoter"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	createfunquoterschema: {
		StepType: 2
		Name:     "createfunquoterschema"
		Order:    16
		Terminal: "term1"
		Language: "cue"
		Renderer: {
			RendererType: 1
		}
		Source: #"""
			package kube

			// First part of demo: using a file directly to verify a stream of YAML objects.
			//
			//    $ cue vet kube.cue -d Object kube.yaml
			//
			// to verify a specific type:
			//
			//    $ cue vet kube.cue -d Service kube.yaml

			// This explains how we tell Kubernetes objects apart.
			Service: kind:    "Service"
			Deployment: kind: "Deployment"

			Object: Deployment | Service

			// Label and selector policy. These constraints fulfil two purposes:
			//
			// 1) automatically derive standard labels as a convenience to the user,
			// 2) check that the value of a namesake preexisitng label is correct.
			//
			// In general, constraints in CUE often serve the purpose of both validation and
			// generation.

			Service: {
			\#t// Note: no need to declare metadata.name here, even though it is referenced
			\#t// below. Types are typically enforced by mixing in complete schema
			\#t// definitions that are defined seperately from policy.
			\#tmetadata: labels: app: metadata.name
			\#tspec: selector: app:   metadata.name
			}
			Deployment: X={
			\#t// X is a value alias for deployment that allows us to refer
			\#t// to metadata without needing to declare it.
			\#tspec: template: metadata: labels: app: X.metadata.name
			}

			// Require monitoring. Note that the top-level schema only suggests
			// monitoring is enabled as a default. This definition goes a bit further
			// in making it a strict requirement.
			//
			// Style tip: put "boilerplate path" on first line and start new lines with
			// path elements that are more meaningfull to the aspect. In this case, the
			// important part is that we are adding an annotation. The fact that these
			// live in the metadata section is less relevant for the understanding.
			Deployment: spec: template: metadata:
			\#tannotations: "prometheus.io/scrape": "true"

			// Enforce the use of the acme.com container registry
			Deployment: spec: template: spec:
			\#tcontainers: [...{
			\#t\#timage: =~"""
			\#t\#t\#t^k3d-registry.acme.com:5000/
			\#t\#t\#t"""
			\#t}]

			"""#
		Target: "/workdir/funquoter/schema.cue"
	}
	firstvet: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "firstvet"
		Order:           17
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "cue vet schema.cue -d Object kube.yaml"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	checknothingtoapply: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "checknothingtoapply"
		Order:           18
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "kubectl apply -f kube.yaml"
			ExitCode: 0
			Output: """
				service/funquoter unchanged
				deployment.apps/funquoter unchanged

				"""
			ComparisonOutput: """
				service/funquoter unchanged
				deployment.apps/funquoter unchanged

				"""
		}]
	}
	createinframonteam: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "createinframonteam"
		Order:           19
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "cd /workdir"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}, {
			Negated:          false
			CmdStr:           "mkdir -p /workdir/infra/mon"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	inframon: {
		StepType: 2
		Name:     "inframon"
		Order:    20
		Terminal: "term1"
		Language: "cue"
		Renderer: {
			RendererType: 1
		}
		Source: """
			package mon

			// This aspect of Deployment defaults Prometheus scraping to true.
			// As a policy, teams are expected to set up Prometheus scraping. They can
			// disable it explicitly if needed.
			Deployment: spec: template: metadata: annotations:
			\t"prometheus.io/scrape": *"true" | "false"

			// ACME Co's standardized app framework has a built in HTTP handler for health
			// checks. This sets this up by default. As a policy, if teams opt to use
			// a different framework, then still need to implement this handler.
			//
			// NOTE: in a real-life scenario, this would probably not be maintained by
			// the monitoring team. :)
			Deployment: spec: template: spec: containers: [...{
			\tlivenessProbe: {
			\t\thttpGet: {
			\t\t\tpath: "/debug/health"
			\t\t\tport: *8080 | int
			\t\t}
			\t\tinitialDelaySeconds: *40 | >10
			\t\tperiodSeconds:       *3 | int
			\t}
			}]

			"""
		Target: "/workdir/infra/mon/mon.cue"
	}
	cuemodinit: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "cuemodinit"
		Order:           21
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "cue mod init acme.com/x"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	returnfunquoter: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "returnfunquoter"
		Order:           22
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "cd funquoter"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	pullmon: {
		StepType: 2
		Name:     "pullmon"
		Order:    23
		Terminal: "term1"
		Language: "cue"
		Renderer: {
			RendererType: 1
		}
		Source: """
			package kube

			import "acme.com/x/infra/mon"

			// mon.Deployment is the policy defined for Deployment as defined by the
			// monitoring team.
			Deployment: mon.Deployment

			"""
		Target: "/workdir/funquoter/mon.cue"
	}
	yamlpullmodel: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "yamlpullmodel"
		Order:           24
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "cue export :kube --out yaml -d Object kube.yaml"
			ExitCode: 0
			Output: """
				apiVersion: v1
				kind: Service
				metadata:
				  name: funquoter
				  labels:
				    app: funquoter
				spec:
				  selector:
				    app: funquoter
				  ports:
				    - protocol: TCP
				      port: 80
				      targetPort: 3000
				---
				apiVersion: apps/v1
				kind: Deployment
				metadata:
				  name: funquoter
				spec:
				  replicas: 1
				  selector:
				    matchLabels:
				      app: funquoter
				  template:
				    metadata:
				      labels:
				        app: funquoter
				      annotations:
				        prometheus.io/scrape: "true"
				    spec:
				      containers:
				        - name: application
				          image: k3d-registry.acme.com:5000/fosdem2022/funquoter
				          imagePullPolicy: Always
				          livenessProbe:
				            httpGet:
				              path: /debug/health
				              port: 8080
				            initialDelaySeconds: 40
				            periodSeconds: 3
				          args:
				            - -addr=quoteserver:80
				            - -requote=10s

				"""
			ComparisonOutput: """
				apiVersion: v1
				kind: Service
				metadata:
				  name: funquoter
				  labels:
				    app: funquoter
				spec:
				  selector:
				    app: funquoter
				  ports:
				    - protocol: TCP
				      port: 80
				      targetPort: 3000
				---
				apiVersion: apps/v1
				kind: Deployment
				metadata:
				  name: funquoter
				spec:
				  replicas: 1
				  selector:
				    matchLabels:
				      app: funquoter
				  template:
				    metadata:
				      labels:
				        app: funquoter
				      annotations:
				        prometheus.io/scrape: "true"
				    spec:
				      containers:
				        - name: application
				          image: k3d-registry.acme.com:5000/fosdem2022/funquoter
				          imagePullPolicy: Always
				          livenessProbe:
				            httpGet:
				              path: /debug/health
				              port: 8080
				            initialDelaySeconds: 40
				            periodSeconds: 3
				          args:
				            - -addr=quoteserver:80
				            - -requote=10s

				"""
		}]
	}
	rmpullmodel: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "rmpullmodel"
		Order:           25
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "rm mon.cue"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	pushmon: {
		StepType: 2
		Name:     "pushmon"
		Order:    26
		Terminal: "term1"
		Language: "cue"
		Renderer: {
			RendererType: 1
		}
		Source: """
			package kube

			import "acme.com/x/infra/mon"

			// Enforce monitoring policies for all teams
			Deployment: mon.Deployment

			"""
		Target: "/workdir/schema.cue"
	}
	yamlpushmodel: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "yamlpushmodel"
		Order:           27
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "cue export :kube --out yaml -d Object kube.yaml"
			ExitCode: 0
			Output: """
				apiVersion: v1
				kind: Service
				metadata:
				  name: funquoter
				  labels:
				    app: funquoter
				spec:
				  selector:
				    app: funquoter
				  ports:
				    - protocol: TCP
				      port: 80
				      targetPort: 3000
				---
				apiVersion: apps/v1
				kind: Deployment
				metadata:
				  name: funquoter
				spec:
				  replicas: 1
				  selector:
				    matchLabels:
				      app: funquoter
				  template:
				    metadata:
				      labels:
				        app: funquoter
				      annotations:
				        prometheus.io/scrape: "true"
				    spec:
				      containers:
				        - name: application
				          image: k3d-registry.acme.com:5000/fosdem2022/funquoter
				          imagePullPolicy: Always
				          livenessProbe:
				            httpGet:
				              path: /debug/health
				              port: 8080
				            initialDelaySeconds: 40
				            periodSeconds: 3
				          args:
				            - -addr=quoteserver:80
				            - -requote=10s

				"""
			ComparisonOutput: """
				apiVersion: v1
				kind: Service
				metadata:
				  name: funquoter
				  labels:
				    app: funquoter
				spec:
				  selector:
				    app: funquoter
				  ports:
				    - protocol: TCP
				      port: 80
				      targetPort: 3000
				---
				apiVersion: apps/v1
				kind: Deployment
				metadata:
				  name: funquoter
				spec:
				  replicas: 1
				  selector:
				    matchLabels:
				      app: funquoter
				  template:
				    metadata:
				      labels:
				        app: funquoter
				      annotations:
				        prometheus.io/scrape: "true"
				    spec:
				      containers:
				        - name: application
				          image: k3d-registry.acme.com:5000/fosdem2022/funquoter
				          imagePullPolicy: Always
				          livenessProbe:
				            httpGet:
				              path: /debug/health
				              port: 8080
				            initialDelaySeconds: 40
				            periodSeconds: 3
				          args:
				            - -addr=quoteserver:80
				            - -requote=10s

				"""
		}]
	}
	kubetools: {
		StepType: 2
		Name:     "kubetools"
		Order:    28
		Terminal: "term1"
		Language: "cue"
		Renderer: {
			RendererType: 1
		}
		Source: """
			package kube

			import (
			\t"strings"
			\t"encoding/yaml"
			\t"encoding/json"

			\t"tool/file"
			\t"tool/cli"
			\t"tool/exec"
			)

			// -- Global tasks

			// glob matches the YAML files in the current directory.
			globYAML: file.Glob & {
			\tglob: "*.yaml"
			}

			open: {
			\tfor _, f in globYAML.files {
			\t\t(f): file.Read & {
			\t\t\tfilename: f

			\t\t\tcontents: _
			\t\t\tdata:     yaml.UnmarshalStream(contents)
			\t\t}
			\t}
			}

			// allTasks lists all tasks run to fetch the configuration. Other tasks
			//
			allTasks: {glob: globYAML, open}

			// -- Linking results into schema

			// Put results into the object map as defined in our top-level schema.
			objByKind: {
			\tfor v in open for obj in v.data {
			\t\t(strings.ToLower(obj.kind)): (obj.metadata.name): obj
			\t}
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
			\ttext: json.MarshalStream(allObjects)
			}

			// apply sends the k8s objects off to kubectl.
			command: apply: exec.Run & {
			\tcmd:   "kubectl apply -f -"
			\tstdin: yaml.MarshalStream(allObjects)
			}

			"""
		Target: "/workdir/kube_tool.cue"
	}
	updaterootschemafortools: {
		StepType: 2
		Name:     "updaterootschemafortools"
		Order:    29
		Terminal: "term1"
		Language: "cue"
		Renderer: {
			RendererType: 1
		}
		Source: """
			package kube

			// This schema can be used anywhere within the module to verify files using
			// the following, or similar, commands:
			//
			//    $ cue vet :kube -d Object kube.yaml
			//
			// Here, :kube tells CUE to load the kube package scoped from the current
			// directory, creating a "package instance". A package instance includes all
			// constraints defined in the package (in this case "kube") from the current
			// directory and all its ancestor directories within the same CUE module, which
			// is marked by the cue.mod directory.

			import (
			\t"acme.com/x/infra/mon"
			)

			// This explains how we tell Kubernetes objects apart.
			//
			// For those already familiar with CUE, note that Service and Deployment
			// are not defined as definitions (#Service and #Deployment). This is a result
			// of how these definitions evolved. They started as constraints on YAML,
			// without any underlying schema. In other words, the schema were not known.
			// As soon as schema are mixed in (see kube_defs.cue),  however, Service and
			// Deployment will behave identically.
			//
			// A drawback of using "regular" fields for these definitions is that they will
			// be output as part of export and friends. As a matter of style, we
			// distinguish the types from data fields by starting them with an uppercase
			// letter, but export does not similarly distinguish such fields.
			//
			// In this application that is not an issue that the types are considered to
			// be data. In case it is, though, there are several alternatives:
			// 1) move the types to a separate packages, allowing to refer to them as,
			//    for instance, types.Service and types.Deployment. This looks neat, but
			//    makes it harder to use hierarchical constraints.
			// 2) use hidden fields: _Service and _Deployment. Like definitions, hidden
			//    fields are excluded from exports.
			// 3) we could support a @export(ignore) attribute to exclude fields.
			//    We would love to hear from you if you are interested in this feature.
			Service: kind:    "Service"
			Deployment: kind: "Deployment"

			Object: Deployment | Service

			// We define a standard place for all our Kubernetes objects to live,
			// collated by kind.
			objByKind: service: [string]:    Service
			objByKind: deployment: [string]: Deployment

			// Style tip: rather than grouping constraints per Kubernetes object type, we
			// group constraints by topic. This makes it easier to see the relationship
			// between constraints and also makes it much easier to move constraints around
			// later.
			//
			// A special case of this is defining default values. As a general guideline,
			// default values should not be defined within schema, but rather as a seperate
			// aspect that then may or may not be mixed in unconditionally by a user.

			// Our monitoring specialists have defined these to help ensure that
			// our services get monitored properly.
			Deployment: mon.Deployment

			// Label and selector policy for Kubernetes objects: this section defines a set of
			// standardized labels for service. This standard was adopted from our friendly
			// folks of the Frontend team.
			//
			// Style tip: to make it clearer that two declarations belong together one could
			// us an embedding to group them. Alternatively, one can have the convention of
			// not using an extra newline between definitions. The embedding approach,
			// though, has the advantage that comments will be grouped logically in the
			// parse tree. This may matter for automation.
			{
			\tService: {
			\t\tmetadata: labels: app: metadata.name
			\t\tspec: selector: app:   metadata.name
			\t}

			\tDeployment: X={
			\t\t// We can refer to a section (here metadata) without having it declared
			\t\t// by adding an alias to the enclosing value. As a general rule one
			\t\t// should use a value alias (a: X=b) as opposed to a field alias (X=a:
			\t\t// b) to the most-inner scope of the section one wishes to refer to.
			\t\tspec: template: metadata: labels: app: X.metadata.name
			\t}
			}

			// This Service aspect defines a set of preferred values for ports.
			// Teams can omit standard values in their configuration, causing any
			// non-default values to stand out.
			Service: spec: ports: [...{
			\tport:       *8080 | int
			\ttargetPort: *port | int
			\tprotocol:   *"TCP" | "UDP"
			}]

			"""
		Target: "/workdir/schema.cue"
	}
	runinitialcmdprint: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "runinitialcmdprint"
		Order:           30
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "cue cmd print"
			ExitCode: 0
			Output: """
				{"apiVersion":"v1","kind":"Service","metadata":{"name":"funquoter","labels":{"app":"funquoter"}},"spec":{"selector":{"app":"funquoter"},"ports":[{"protocol":"TCP","port":80,"targetPort":3000}]}}
				{"apiVersion":"apps/v1","kind":"Deployment","metadata":{"name":"funquoter"},"spec":{"replicas":1,"selector":{"matchLabels":{"app":"funquoter"}},"template":{"metadata":{"labels":{"app":"funquoter"},"annotations":{"prometheus.io/scrape":"true"}},"spec":{"containers":[{"name":"application","image":"k3d-registry.acme.com:5000/fosdem2022/funquoter","imagePullPolicy":"Always","livenessProbe":{"httpGet":{"path":"/debug/health","port":8080},"initialDelaySeconds":40,"periodSeconds":3},"args":["-addr=quoteserver:80","-requote=10s"]}]}}}}


				"""
			ComparisonOutput: """
				{"apiVersion":"v1","kind":"Service","metadata":{"name":"funquoter","labels":{"app":"funquoter"}},"spec":{"selector":{"app":"funquoter"},"ports":[{"protocol":"TCP","port":80,"targetPort":3000}]}}
				{"apiVersion":"apps/v1","kind":"Deployment","metadata":{"name":"funquoter"},"spec":{"replicas":1,"selector":{"matchLabels":{"app":"funquoter"}},"template":{"metadata":{"labels":{"app":"funquoter"},"annotations":{"prometheus.io/scrape":"true"}},"spec":{"containers":[{"name":"application","image":"k3d-registry.acme.com:5000/fosdem2022/funquoter","imagePullPolicy":"Always","livenessProbe":{"httpGet":{"path":"/debug/health","port":8080},"initialDelaySeconds":40,"periodSeconds":3},"args":["-addr=quoteserver:80","-requote=10s"]}]}}}}


				"""
		}]
	}
	runinitialcmdapply: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "runinitialcmdapply"
		Order:           31
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "cue cmd apply"
			ExitCode: 0
			Output: """
				service/funquoter unchanged
				deployment.apps/funquoter configured

				"""
			ComparisonOutput: """
				service/funquoter unchanged
				deployment.apps/funquoter configured

				"""
		}]
	}
	initialkubedefs: {
		StepType: 2
		Name:     "initialkubedefs"
		Order:    32
		Terminal: "term1"
		Language: "cue"
		Renderer: {
			RendererType: 1
		}
		Source: """
			package kube

			import (
			\t"k8s.io/api/core/v1"
			\tapps_v1 "k8s.io/api/apps/v1"
			)

			// Mix in imported schema.
			//
			// Note that even though Service and Deployment are not defined as definitions,
			// mixing in the generated definitions from k8s.io will make them behave
			// as if they were.

			Service:    v1.#Service
			Deployment: apps_v1.#Deployment

			"""
		Target: "/workdir/kube_defs.cue"
	}
	failingcuecmdapply: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "failingcuecmdapply"
		Order:           33
		Terminal:        "term1"
		Stmts: [{
			Negated:  true
			CmdStr:   "cue cmd apply"
			ExitCode: 1
			Output: """
				import failed: cannot find package "k8s.io/api/apps/v1":
				    ../kube_defs.cue:5:2

				"""
			ComparisonOutput: """
				import failed: cannot find package "k8s.io/api/apps/v1":
				    ../kube_defs.cue:5:2

				"""
		}]
	}
	cuedeps: {
		StepType: 2
		Name:     "cuedeps"
		Order:    34
		Terminal: "term1"
		Language: "go"
		Renderer: {
			RendererType: 1
		}
		Source: """
			//go:build cue
			// +build cue

			package cue

			import _ "k8s.io/api/apps/v1"

			"""
		Target: "/workdir/cue_deps.go"
	}
	getgo: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "getgo"
		Order:           35
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "go get k8s.io/api/apps/v1@v0.23.2"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	cuegetgo: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "cuegetgo"
		Order:           36
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "cue get go k8s.io/api/apps/v1"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	nowworkingapply: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "nowworkingapply"
		Order:           37
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "cue cmd apply"
			ExitCode: 0
			Output: """
				service/funquoter unchanged
				deployment.apps/funquoter unchanged

				"""
			ComparisonOutput: """
				service/funquoter unchanged
				deployment.apps/funquoter unchanged

				"""
		}]
	}
	cueimport: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "cueimport"
		Order:           38
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "cue import -p kube -l 'objByKind:' -l 'strings.ToCamel(kind)' -l metadata.name kube.yaml"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	inspectimportedcue: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "inspectimportedcue"
		Order:           39
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "cat kube.cue"
			ExitCode: 0
			Output: """
				package kube

				objByKind: service: funquoter: {
				\tapiVersion: "v1"
				\tkind:       "Service"
				\tmetadata: {
				\t\tname: "funquoter"
				\t\tlabels: app: "funquoter"
				\t}
				\tspec: {
				\t\tselector: app: "funquoter"
				\t\tports: [{
				\t\t\tprotocol:   "TCP"
				\t\t\tport:       80
				\t\t\ttargetPort: 3000
				\t\t}]
				\t}
				}
				objByKind: deployment: funquoter: {
				\tapiVersion: "apps/v1"
				\tkind:       "Deployment"
				\tmetadata: name: "funquoter"
				\tspec: {
				\t\treplicas: 1
				\t\tselector: matchLabels: app: "funquoter"
				\t\ttemplate: {
				\t\t\tmetadata: labels: app: "funquoter"
				\t\t\tspec: containers: [{
				\t\t\t\tname:            "application"
				\t\t\t\timage:           "k3d-registry.acme.com:5000/fosdem2022/funquoter"
				\t\t\t\timagePullPolicy: "Always"
				\t\t\t\targs: [
				\t\t\t\t\t"-addr=quoteserver:80",
				\t\t\t\t\t"-requote=10s",
				\t\t\t\t]
				\t\t\t}]
				\t\t}
				\t}
				}

				"""
			ComparisonOutput: """
				package kube

				objByKind: service: funquoter: {
				\tapiVersion: "v1"
				\tkind:       "Service"
				\tmetadata: {
				\t\tname: "funquoter"
				\t\tlabels: app: "funquoter"
				\t}
				\tspec: {
				\t\tselector: app: "funquoter"
				\t\tports: [{
				\t\t\tprotocol:   "TCP"
				\t\t\tport:       80
				\t\t\ttargetPort: 3000
				\t\t}]
				\t}
				}
				objByKind: deployment: funquoter: {
				\tapiVersion: "apps/v1"
				\tkind:       "Deployment"
				\tmetadata: name: "funquoter"
				\tspec: {
				\t\treplicas: 1
				\t\tselector: matchLabels: app: "funquoter"
				\t\ttemplate: {
				\t\t\tmetadata: labels: app: "funquoter"
				\t\t\tspec: containers: [{
				\t\t\t\tname:            "application"
				\t\t\t\timage:           "k3d-registry.acme.com:5000/fosdem2022/funquoter"
				\t\t\t\timagePullPolicy: "Always"
				\t\t\t\targs: [
				\t\t\t\t\t"-addr=quoteserver:80",
				\t\t\t\t\t"-requote=10s",
				\t\t\t\t]
				\t\t\t}]
				\t\t}
				\t}
				}

				"""
		}]
	}
	cuetrim: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "cuetrim"
		Order:           40
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "cue trim -s"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
	trimmedapply: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "trimmedapply"
		Order:           41
		Terminal:        "term1"
		Stmts: [{
			Negated:  false
			CmdStr:   "cue cmd apply"
			ExitCode: 0
			Output: """
				service/funquoter unchanged
				deployment.apps/funquoter unchanged

				"""
			ComparisonOutput: """
				service/funquoter unchanged
				deployment.apps/funquoter unchanged

				"""
		}]
	}
	noyamlapply: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: false
		Name:            "noyamlapply"
		Order:           42
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "rm kube.yaml"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}, {
			Negated:  false
			CmdStr:   "cue cmd apply"
			ExitCode: 0
			Output: """
				service/funquoter unchanged
				deployment.apps/funquoter unchanged

				"""
			ComparisonOutput: """
				service/funquoter unchanged
				deployment.apps/funquoter unchanged

				"""
		}]
	}
	tidyup: {
		StepType:        1
		DoNotTrim:       false
		InformationOnly: true
		Name:            "tidyup"
		Order:           43
		Terminal:        "term1"
		Stmts: [{
			Negated:          false
			CmdStr:           "k3d cluster delete acme.com >/dev/null 2>&1 || true"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}, {
			Negated:          false
			CmdStr:           "k3d registry delete registry.acme.com >/dev/null 2>&1 || true"
			ExitCode:         0
			Output:           ""
			ComparisonOutput: ""
		}]
	}
}
Hash: "3d97afd20c4e5ad7b59db4c701babfe5a8feb9667b90b88649beea7e3a4d054c"
Delims: ["{{{", "}}}"]
