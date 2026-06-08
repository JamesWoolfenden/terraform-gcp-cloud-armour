resource "google_compute_security_policy" "default" {
  name = var.cloudarmour_rule_name

  rule {
    action      = "deny(403)"
    priority    = "2147483647"
    description = "Default rule"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  #checkov:skip=CKV_GCP_73: False trigger
  rule {
    action      = "deny(403)"
    priority    = "0"
    description = "log4j CVE canary — evaluated before all allow rules"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('cve-canary')"
      }
    }
  }

  dynamic "rule" {
    for_each = chunklist(sort(var.cloudarmour_rule_ips), 10)

    content {
      action      = "allow"
      priority    = rule.key + 1
      description = "Allowlisted IP range group ${rule.key + 1}"

      match {
        versioned_expr = "SRC_IPS_V1"

        config {
          src_ip_ranges = rule.value
        }
      }
    }
  }

  log_config {
    enable = true
  }
}
