# required
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

  rule {
    action      = "deny(403)"
    priority    = "2147483646"
    description = "log4j"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('cve-canary')"
      }
    }
  }

  dynamic "rule" {
    for_each = chunklist(sort(var.cloudarmour_rule_ips), 10)

    content {
      action   = "allow"
      priority = rule.key + 1

      match {
        versioned_expr = "SRC_IPS_V1"

        config {
          src_ip_ranges = rule.value
        }
      }
    }
  }
}
