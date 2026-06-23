variable "region" {
  type        = string
  description = "GCP region for the demo Cloud Run service fronted by the Cloud Armor policy."
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "The region must be a non-empty string."
  }
}
