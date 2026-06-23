output "cloud_armour" {
  value       = module.CloudArmour
  description = "All outputs from the cloud_armour module, including the Cloud Armor security policy."
}

output "ip" {
  value       = module.ip
  description = "Contains IP information"
}

output "demo_url" {
  value       = "http://${google_compute_global_forwarding_rule.demo.ip_address}"
  description = "URL of the demo backend, fronted end-to-end by the Cloud Armor policy."
}
