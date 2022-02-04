package kube

import (
	"k8s.io/api/core/v1"
	apps_v1 "k8s.io/api/apps/v1"
)

// Mix in imported schema.
//
// Note that even though Service and Deployment are not defined as definitions,
// mixing in the generated definitions from k8s.io will make them behave
// as if they were.

Service:    v1.#Service
Deployment: apps_v1.#Deployment
