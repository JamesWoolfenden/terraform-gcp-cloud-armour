variable "cloudarmour_rule_name" {
  type        = string
  description = "Cloud Armor security policy name. Must be 1-63 characters, lowercase letters, digits or hyphens, starting with a letter."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.cloudarmour_rule_name))
    error_message = "cloudarmour_rule_name must be 2-63 characters, start with a lowercase letter, end with a letter or digit, and contain only lowercase letters, digits or hyphens."
  }
}

variable "cloudarmour_rule_ips" {
  type        = list(string)
  description = "List of IP CIDR ranges to allowlist (e.g. [\"203.0.113.0/24\", \"198.51.100.1/32\"]). Must be non-empty."

  validation {
    condition     = length(var.cloudarmour_rule_ips) > 0 && alltrue([for ip in var.cloudarmour_rule_ips : can(cidrhost(ip, 0))])
    error_message = "cloudarmour_rule_ips must be a non-empty list of valid CIDR blocks (e.g. \"203.0.113.0/24\")."
  }
}
