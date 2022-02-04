---
layout: post
title:  "A practical guide to CUE: patterns for everyday use"
excerpt: "A worked example of CUE adoption in a Go, Kubernetes and grpc-based setup"
difficulty: Beginner
---

### Introduction

At [FOSDEM 2022](https://fosdem.org/2022/), [Marcel van
Lohuizen](https://twitter.com/mpvl_) and [Paul
Jolly](https://twitter.com/_myitcv) presented ["A practical guide to CUE:
patterns for everyday
use"](https://fosdem.org/2022/schedule/event/cue_pratical_guide/). A recording
of the talk will soon be made available on https://video.fosdem.org/2022.
Meanwhile, the slides are available
[here](https://docs.google.com/presentation/d/1BycB_WevWQfzSoyGHuAIQOWQhbq4npU2aPVs14tiDa4/edit?usp=sharing).

The main goal of the talk is to present a practical guide to CUE with patterns
and techniques to help drive CUE adoption in your project or company.

The talk features a demonstration in which we imagine what such an adoption path
might look like for Acme.com, a fictional company who have a simple Go,
Kubernetes and grpc-based setup. The demo shows how and where the company
gradually adopt CUE.

This guide allows you to recreate the demo locally, step-by-step, using a Docker
container for convenience. We explain how to get started below, but first some
background on Acme.com.

### Acme.com

Acme.com's entire system (it's very small) is composed of two fictional
services, each a Go program:

* `{{{.Quoteserver}}}`
* `{{{.Funquoter}}}`

`{{{.Funquoter}}}` is incredibly simple and for now does not expose any API.
Every 10 seconds, as a test, `{{{.Funquoter}}}` requests a number of quotes from
`{{{.Quoteserver}}}` and logs the famous and recognisable proverbs to stdout.

The `quote` package imported by both `{{{.Quoteserver}}}` and `{{{.Funquoter}}}`
defines a grpc-based `Quoter` service with a single method `Quote`.

The infra team are responsible for the upkeep of the system.

For the sake of keeping the example simple, Acme.com keep all their code a
single or mono repository (just to be clear this is absolutely not a requirement
for the use of CUE).

### Running the demo locally

To play around with CUE and get familiar with what is possible, you can recreate
the demo yourself locally from start to finish.

The simplest way to get started is to use the `{{{ .DockerImage }}}` Docker
image:

```
$ git clone https://github.com/{{{ .DemoRepo }}}
$ cd {{{ .DemoRepoName }}}
$ ./docker/run.sh
```

The last command will drop you into a minimal Docker container that has all the
tools necessary for working through the example from start to end, following the
steps outlined below.

The `{{{ .WorkdirMount }}}` directory inside the `{{{ .DemoRepoName }}}`
directory you cloned is mounted at `{{{ .Workdir }}}` inside the Docker
container. You can therefore edit files using your favourite editor outside of
the container, and simply issue commands within the container.

You are now ready to get started! Run each of the commands listed below within
the Docker container, and create/update files according to the path shown as a
comment at the top of each file using your editor outside of the container.

If you encounter any issues working through the demo, please [raise an
issue](https://github.com/{{{ .DemoRepo }}}/issues/new).

Good luck!

### Requirements

This demo uses CUE version:

{{{ step "cueversion" }}}

and Go version:

{{{ step "goversion" }}}

Type or copy/paste these commands into your container, and you should see the
same output.

### Preiminary setup

Running within the container, change to the working directory where the `{{{
.WorkdirMount }}}` directory is mounted.

{{{ step "cdworkdir" }}}

This corresponds to `{{{ .WorkdirMount }}}` in the clone of the demo.

Create a `k3s` registry and cluster:

{{{ step "startcluster" }}}

Tell `kubectl` which cluster to use:

{{{ step "exportenv" }}}

Build images for `{{{.Funquoter}}}` and `{{{.Quoteserver}}}` services:

{{{ step "buildimages" }}}

Start the `{{{.Funquoter}}}` and `{{{.Quoteserver}}}` services:

{{{ step "startpods" }}}

### Exploring the example

You should still be at the root of the example:

{{{ step "pwdroot" }}}

Acme.com have defined all of their services under a single Go module:

{{{ step "modulelist" }}}

The `{{{.Quoteserver}}}` and `{{{.Funquoter}}}` packages also contain the k8s
declarations and `Dockerfile` for each service:

{{{ step "lsfunquoterquoteserver" }}}

Confirm your system is now running:

{{{ step "getpods" }}}

To see `{{{.Funquoter}}}` in action you can watch its logs:

{{{ step "initialfunquoterlogs" }}}

For now `{{{.Funquoter}}}` is only requesting a single quote from `{{{.Quoteserver}}}`, and
`{{{.Quoteserver}}}` is hard coded to return the well-known [Go
proverb](https://go-proverbs.github.io/) shown above.

### Validation

Now the `{{{.Funquoter}}}` team have been keeping up with the latest trends and have
heard about CUE They are keen to try and adopt CUE in their workflow .  But a
strict requirement for now is they want to continue maintaining YAML files for
Kubernetes service declarations So where to start?

A good place start is to use CUE to validate existing YAML K8s definitions and
to do so incrementally. CUE's compositional model will allow the team to start
with basic constraints, adding more validation bit by bit.

The `{{{ .Funquoter }}}` team start by declaring some basic constraints that
describe the structure of their service.

They do so in `{{{ .FunquoterSchema }}}`.

Change to the `{{{ .Funquoter }}}` directory:

{{{ step "cdfunquotervalidate" }}}

Create `schema.cue` using your favourite editor within the `workdir/funquoter`
directory in the `{{{.DemoRepoName}}}` directory you cloned from GitHub:

{{{ step "createfunquoterschema" }}}

The team declare an `Object` to be a `Deployment` or `Service` using a
[disjunction](https://cuelang.org/docs/references/spec/#disjunction).  For those
familiar with Kubernetes declarations, `Deployment` and `Service` objects are
identifiable by the `kind` field We refer to `kind` field acts as a
discriminator - it determines whether an object is a deployment or a service.

For those familiar with CUE, note that the team are not writing
[definitions](https://cuelang.org/docs/references/spec/#definitions-and-hidden-fields).
They don’t yet have a schema for all the fields - they only have an incomplete
declaration.

Similarly, they could have written one big declaration for `Deployment` and
`Service`, but presented this way you can see how it is easy to group related
rules together.

The team enforce the use of the Acme.com image registry for all their deployments, by constraining
the `image` field to match the regular expression shown.

For any service declaration, the team constrain the `metadata` name to be
consistent with the `app` `label`, and the `spec` `selector` `app`.  For
deployments, the team use a value alias, `X`, to access the top-level `metadata`
field without having to define it. They then constrain the `metadata` `name` to
be consistent with the `spec` `template` `metadata` `label` `app`.

CUE's compositional model allows the team to break down their configuration into
important pieces piecemeal, gradually refining their definitions to be more
specific

Note all of this work is entirely independent of the quoteserver and other teams
Not only that, the workflow of editing YAML files remains untouched.

The team use `cue vet` to validate their Kubernetes configuration using
the constraints in `schema.cue`.

{{{ step "firstvet" }}}

The `-d` flag specifies an expression that selects the schema to apply to
non-CUE files.  In this case you want to vet `kube.yaml` against `Object`.  `cue
vet` processes the stream of YAML. The `Object` schema matches YAML objects by
the `kind` field, and applies the relevant constraints.

Thankfully the team's configuration passes! If it didn't you would see some
output from the command above. Indeed try and change `funquoter/kube.yaml` and
re-run the `cue vet` command to see how CUE alerts you when the data does not
satisfy the schema.

At this stage you have only validated the Kubernetes configuration satisfies the
basic schema declared in `schema.cue`. There should be no changes to apply to
the `{{{.Funquoter}}}` service, something you can confirm via:

{{{ step "checknothingtoapply" }}}

### File organization: sharing CUE validation and policy

The Acme.com infrastructure team provides monitoring services to other teams.
They want to declare some CUE constraints on deployment configurations.

The infrastructure team create a directory structure of their own:

{{{ step "createinframonteam" }}}

and specify the following constraints:

{{{ step "inframon" }}}

They specify that a deployment should have Prometheus scraping on by default.
Teams will have to explicitly disable it to turn it off.

The second aspect specifies that a deployment _must_ have a liveness probe at a
predetermined path.  This can be handy, for instance, if an organisation uses a
common application framework that standardizes on these things.

There are a few things to note here. There are two entries for `Deployment`.
This is realy composition in action: CUE will automatically combine these
together.  To reemphasize, in general, we think it is good style to split such
“rules” into aspects of related functionality, rather than having one big blob
per type. This enhances readability and makes it easier to refactor code.

Another style point here is that paths are split to put the boilerplate path
on the first line, and then the more meaningful part of the path on the second
line.  So on the first line you can immediately see the type of object it applies
to, whereas on the second line you can quickly scan to see the essence of what
the rule is doing.

To use these constraints via [the "pull"
model](https://docs.google.com/presentation/d/1BycB_WevWQfzSoyGHuAIQOWQhbq4npU2aPVs14tiDa4/edit#slide=id.g10e62fd42dd_1_624),
the `{{{.Funquoter}}}` team need to be able to import the `infra/mon` package. To do
that, the packages must live within a [CUE
module](https://cuelang.org/docs/concepts/packages/):

{{{ step "cuemodinit" }}}

Returning to the `{{{.Funquoter}}}` directory:

{{{ step "returnfunquoter" }}}

The `{{{.Funquoter}}}` team now further constrain a `Deployment` by the infrastructure
team's `Deployment` constraints:

{{{ step "pullmon" }}}

You can use `cue export` to see the result of evaluating the `kube` package and
`kube.yaml`: The `–out` flag indicates the result should be rendered as YAML:

{{{ step "yamlpullmodel" }}}

Compare the output above with the contents of `kube.yaml` to see how the
liveness probe configuration has been added.

Note: this doesn’t enforce that it is implemented, of course. That has to be
dealt with at other locations.

But CUE also has another mechanism that conforms more to the cross-cutting
nature of configuration.

For example, suppose the monitoring team wants to enforce the constraints
shown above as matter of policy, rather than relying on each team pulling them
in explicitly through an import. This is referred to as [the "push"
model](https://docs.google.com/presentation/d/1BycB_WevWQfzSoyGHuAIQOWQhbq4npU2aPVs14tiDa4/edit#slide=id.g10e62fd42dd_1_590).

To see that in action, first remove the file in which the `{{{.Funquoter}}}` team
imported (pulled) the monitoring team's constraints:

{{{ step "rmpullmodel" }}}

To use the "push" model, the monitoring team apply the same change as before,
but at higher level directory so that it spans different packages across the
organization.

{{{ step "pushmon" }}}

This is really the same change as the `{{{.Funquoter}}}` team made earlier, with the
main difference being that now these constraints are added outside the control
of the teams of the relevant subdirectories, meaning that the same constraints
now function as a policy rather than as a data template.

Verify that the liveness probe is still added to the resulting exported
`{{{.Funquoter}}}` service configuration:

{{{ step "yamlpushmodel" }}}

### The tooling layer: formalizing the process

Thus far you have manually verified Kubernetes YAML files with CUE on the
command line.

You can automate that process with the tooling layer: a declarative workflow
mechanism supported by CUE.

Using higher-level commands you will validate the YAML files as a byproduct,
rather than having to do this explicitly.

There are various ways to accomplish this, so what follows is not supposed to be
prescriptive but rather serve to highlight the possibilities.

The goal here is to write a single workflow, capturing common functionality,
that can be used — and possibly tailored — by all teams.

Declare a `kube_tool.cue` file as follows:

{{{ step "kubetools" }}}

And update `schema.cue` in the root of the repository as follows:

{{{ step "updaterootschemafortools" }}}

Refer to the
[slides](https://docs.google.com/presentation/d/1BycB_WevWQfzSoyGHuAIQOWQhbq4npU2aPVs14tiDa4/edit#slide=id.g10e62fd42dd_1_453)
to see how the description that follows corresponds to the file you just
created.

The first step for control flow is to load the YAML files. We plan to have
native support for having JSON and YAML included in packages directly, but for
now you have to do this.

A CUE workflow consists of task. Tasks are CUE values that tell CUE what action
to take, describing inputs and outputs.  All tasks are defined in the
[`pkg/tool/...`](https://pkg.go.dev/cuelang.org/go/pkg/tool) package hierarchy.

A task gets triggered when all its input fields are specified, writing the
results to the output fields.

CUE automatically determines dependencies between tasks based on references
between them. So if an input one task references the output of another task, it
is automatically run after it.

In the file above, you can see two different tasks: the first task, `globYAML`, finds
all YAML files in the current directory. The
[comprehension](https://cuelang.org/docs/references/spec/#comprehensions) then
creates a `file.Read` task for each YAML file, each identifiable by a different
path, in this case `open: \(f)`, where `f` is a reference to the filename.

The tasks you see here are global tasks, meaning that they are not associated
with a specific command.

For more details on the `tool/file.Read` and `tool/file.Glob` tasks, see [the
`tool/file`
documentation](https://pkg.go.dev/cuelang.org/go@v0.4.1/pkg/tool/file).  Tasks
are a bit like functions. But instead of it being called, they are structs with
input and output fields that get set upon execution.

After the tasks are run, you need to do something with the read data.

Rather than reading directly from the tasks, you will push the read result into a
map called `objByKind`, which sorts the objects by kind and name.

Of course there are many more object types, but here we focus on `Service` and
`Deployment`.

Then the next step is to actually pull the task results and put them in this
map. That is done by means of a comprehension that populates `objByKind`. We
adopt the convention that all data fields are `camelCase`, so we convert the
kind names by lowercasing them. (`strings.ToCamel` is an example of referencing
non-CUE code.)

As most commands that you will define need a list of all these objects, create
one ahead of time via `allObjects`.

Users can invoke workflows by means of commands, which are basically a grouping
of tasks that can be run by the cue command.

The two commands used in the demo are `print` and `apply`. Each command has only
one task itself. But they can have many tasks in reality. In fact, these
commands actually consist of many tasks, because as you can see, they reference
`allObjects`, which in turn references the global tasks described above.  CUE
runs all dependent tasks as part of the workflow.

Running `cue cmd print` gives you a JSON stream of all objects:

{{{ step "runinitialcmdprint" }}}

The `apply` command lets you `kubectl apply` the result of the CUE evaluation,
the combined result of yaml and CUE constraints you saw as the result of `cue
export`:

{{{ step "runinitialcmdapply" }}}

As expected there is a change to apply here, specifically the liveness probe you
saw earlier which is now mandated as policy by the monitoring team.

As before, running each of these commands will trigger validation errors if
`kube.yaml` does not satisfy the constraints declared by the `{{{.Funquoter}}}` and
monitoring teams. Experiment by changing the hostname of the `{{{.Funquoter}}}`
deployment image URL and then running `cue cmd apply` again.


### Importing schema: making is all Kubernetes aware

So far the `{{{.Funquoter}}}` team have been declaring their own constraints, enforcing
consistency and templating their Kubernetes service But surely the team don't
have to declare the entire service and deployment schemas by hand?  Is there not
a source of truth they can refer to and use that to validate their YAML?

For Kubernetes the source of truth is Go code

CUE natively supports importing and exporting data _and_ schema from multiple
encodings:

Data encodings
JSON
YAML
Schema encodings
OpenAPI
Protobuf
JSON Schema
Language encodings
Go

We have plans to support many many more. Indeed please ensure we have [open
issues](https://github.com/cue-lang/cue/issues) for encodings that you consider
a priority. That helps to make transparent the priority, as others can leave
emoji in support of the proposal

The team want to validate the correctness of the `{{{.Funquoter}}}` service by mixing
in the Kubernetes types imported from Go code.

They do that by further constraining the `Service` and `Deployment` fields by
the imported definitions (again within the root of the repository):

{{{ step "initialkubedefs" }}}

These definitions in the `k8s` packages are the result of the import from Go
code. We plan to have a curated repository of those templates. But for now you
can generate them, as you will see below.

Note that with the change shown above, `cue cmd apply` no longer works:

{{{ step "failingcuecmdapply" }}}

The `acme.com/x` CUE module does not know how to resolve the `k8s` packages. Fix
that by importing those definitions from go code. First step is to declare a Go
dependency on the relevant `k8s` packages:

{{{ step "cuedeps" }}}

Then `go get` the module:

{{{ step "getgo" }}}

Now you can generate the CUE definitions from the Go types:

{{{ step "cuegetgo" }}}

`cue cmd apply` should now work again:

{{{ step "nowworkingapply" }}}

Not only that, but despite now also validating against the full imported schema
there is no change in the resulting configuration, i.e. no delta to apply.

You can verify that the constraints of the imported `k8s` definitions validate
typos in your configuration.  For example, try changing the `replicas` field in
`kube.yaml` to `replica` and then re-run `cue cmd apply`. Be sure to leave the
configuration in a working state!

### Going CUE native

At this point, the `{{{.Funquoter}}}` team are convinced. They want to go all in, and
maintain CUE files instead of YAML.

Certain language and syntax decisions in CUE make that an excellent choice
compared to either JSON or YAML especially because you can leave behind the
world of white space significance. But also optional braces, optional commas,
order irrelevance string interpolation, references, disjunctions, default
values, comprehensions, templates, packages, modules, etc.

The language tooling is also very powerful. `cue fmt` automatically formats CUE
code, and a work-in-progress [language server
protocol](https://github.com/cue-lang/cue/issues/142) implementation will bring
everything from code completion to validation in editor.

Not only that, as you will see `cue trim` allows you to automatically reduce
boilerplate in CUE configurations (something we also plan to support in JSON and
YAML).

Start by importing the existing YAML Kubernetes declarations to CUE using `cue
import`:

{{{ step "cueimport" }}}

The `-p` flag adds the resulting CUE to the `kube` package like all the other
CUE code The `-l` flag defines the path at which the imported YAML is placed. It
can appear multiple times Each imported `{{{.Funquoter}}}` object needs to be placed at
the path: `objByKind`, a field defined by the `kind` of object (for which you
can alter the casing using `strings.ToCamel`), and finally a field defined by
the `metadata.name` of the object.

Look at the result of directly importing YAML to CUE:

{{{ step "inspectimportedcue" }}}

You can simplify the resulting CUE using `cue trim`, removing boiler plate that
is implied by other constraints and schemas:

{{{ step "cuetrim" }}}

Verify you can still `cue cmd apply`:

{{{ step "trimmedapply" }}}

Significantly, there are no changes to be applied which validates that your
import from YAML to CUE, and boiler plate removal with `cue trim`, didn't add or
remove anything.

At this stage the YAML and CUE are living side by side, and both need to be
consistent. Make a change to the YAML at this point and re-run `apply`: you will
notice that `cmd/cue` complains of an inconsitency between the CUE constraints
and the YAML.  Given the `{{{.Funquoter}}}` team want to migrate away from YAML they
can simply remove this file and maintain the CUE file:

{{{ step "noyamlapply" }}}

At this point, the `{{{.Funquoter}}}` service has been fully converted from YAML to CUE.
The team can validate their configuration against the Kubernetes source of truth
definitions, and have removed unnecessary boilerplate that is implied by
constraints elsewhere.

In the process the resulting configuration has changed in only one respect from
the original configuration: namely the monitoring team's policy enforcing a
liveness probe.

