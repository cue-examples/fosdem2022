package mon

// This aspect of Deployment defaults Prometheus scraping to true.
// As a policy, teams are expected to set up Prometheus scraping. They can
// disable it explicitly if needed.
Deployment: spec: template: metadata: annotations:
	"prometheus.io/scrape": *"true" | "false"

// ACME Co's standardized app framework has a built in HTTP handler for health
// checks. This sets this up by default. As a policy, if teams opt to use
// a different framework, then still need to implement this handler.
//
// NOTE: in a real-life scenario, this would probably not be maintained by
// the monitoring team. :)
Deployment: spec: template: spec: containers: [...{
	livenessProbe: {
		httpGet: {
			path: "/debug/health"
			port: *8080 | int
		}
		initialDelaySeconds: *40 | >10
		periodSeconds:       *3 | int
	}
}]
