output "policy" {
  value       = google_compute_security_policy.default
  description = "The Cloud Armor security policy resource. Attach it to a backend service via google_compute_backend_service.security_policy = google_compute_security_policy.default.self_link."
}

output "policy_name" {
  value       = google_compute_security_policy.default.name
  description = "Name of the Cloud Armor security policy."
}

output "policy_self_link" {
  value       = google_compute_security_policy.default.self_link
  description = "Self-link of the Cloud Armor security policy, for use in google_compute_backend_service.security_policy."
}
