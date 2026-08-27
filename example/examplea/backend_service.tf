# Minimal deployable backend so the Cloud Armor policy above has something to
# protect end-to-end: Cloud Run (origin) -> serverless NEG -> backend service
# (security_policy + log_config wired up) -> URL map -> HTTP proxy -> forwarding rule.

# holden:ignore:HLD_GCP_167: its an example
# holden:ignore:HLD_GCP_126: its an example
# holden:ignore:HLD_GCP_084: its an example
# holden:ignore:HLD_GCP_127: its an example
# holden:ignore:HLD_GCP_331: its an example
# holden:ignore:HLD_GCP_332: its an example
# holden:ignore:HLD_GCP_336: its an example
# holden:ignore:HLD_GCP_481: its an example
# holden:ignore:HLD_GCP_480: its an example
# holden:ignore:HLD_GCP_200: its an example — hello-world demo image has no stable tag to pin to
resource "google_cloud_run_v2_service" "demo" {
  name     = "pike-demo"
  location = var.region

  # Traffic only enters via the Cloud Armor-protected load balancer below —
  # the *.run.app URL is not reachable directly.
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}

# holden:ignore:HLD_GCP_018 — required so the external HTTP(S) LB can reach
# Cloud Run via the serverless NEG; ingress is locked to
# INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER above so this is reachable only
# through the Cloud Armor-protected backend service, not directly.
# holden:ignore:HLD_GCP_023: just for the example
resource "google_cloud_run_v2_service_iam_member" "demo_invoker" {
  name     = google_cloud_run_v2_service.demo.name
  location = google_cloud_run_v2_service.demo.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "demo" {
  name                  = "pike-demo-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.demo.name
  }
}

# holden:ignore:HLD_GCP_333: its an example
# holden:ignore:HLD_GCP_335: its an example
resource "google_compute_backend_service" "demo" {
  name                  = "pike-demo-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"

  security_policy = module.CloudArmour.policy_self_link

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.demo.id
  }
}

resource "google_compute_url_map" "demo" {
  name            = "pike-demo-url-map"
  default_service = google_compute_backend_service.demo.id
}

resource "google_compute_target_http_proxy" "demo" {
  name    = "pike-demo-http-proxy"
  url_map = google_compute_url_map.demo.id
}

# holden:ignore:HLD_GCP_241: its an example
# holden:ignore:HLD_GCP_106: its an example
resource "google_compute_global_forwarding_rule" "demo" {
  name                  = "pike-demo-forwarding-rule"
  target                = google_compute_target_http_proxy.demo.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
