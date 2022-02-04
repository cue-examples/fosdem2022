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
	// Note: no need to declare metadata.name here, even though it is referenced
	// below. Types are typically enforced by mixing in complete schema
	// definitions that are defined seperately from policy.
	metadata: labels: app: metadata.name
	spec: selector: app:   metadata.name
}
Deployment: X={
	// X is a value alias for deployment that allows us to refer
	// to metadata without needing to declare it.
	spec: template: metadata: labels: app: X.metadata.name
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
	annotations: "prometheus.io/scrape": "true"

// Enforce the use of the acme.com container registry
Deployment: spec: template: spec:
	containers: [...{
		image: =~"""
			^k3d-registry.acme.com:5000/
			"""
	}]
