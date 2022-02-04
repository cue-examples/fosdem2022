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
	"acme.com/x/infra/mon"
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
	Service: {
		metadata: labels: app: metadata.name
		spec: selector: app:   metadata.name
	}

	Deployment: X={
		// We can refer to a section (here metadata) without having it declared
		// by adding an alias to the enclosing value. As a general rule one
		// should use a value alias (a: X=b) as opposed to a field alias (X=a:
		// b) to the most-inner scope of the section one wishes to refer to.
		spec: template: metadata: labels: app: X.metadata.name
	}
}

// This Service aspect defines a set of preferred values for ports.
// Teams can omit standard values in their configuration, causing any
// non-default values to stand out.
Service: spec: ports: [...{
	port:       *8080 | int
	targetPort: *port | int
	protocol:   *"TCP" | "UDP"
}]
