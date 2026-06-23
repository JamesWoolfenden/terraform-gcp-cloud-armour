# holden:ignore:HLD_GCP_176 — Cloud Armor security policies do not use VPC access; network-level control is on the attached backend service
resource "google_compute_security_policy" "default" {
  name        = var.name
  description = var.description
  type        = var.type

  # Adaptive protection — ML-based Layer 7 DDoS defence (CLOUD_ARMOR only)
  dynamic "adaptive_protection_config" {
    for_each = var.type == "CLOUD_ARMOR" ? [1] : []
    content {
      layer_7_ddos_defense_config {
        enable          = var.adaptive_protection.enable
        rule_visibility = var.adaptive_protection.rule_visibility
      }
    }
  }

  # Advanced options — JSON parsing and log verbosity (CLOUD_ARMOR only)
  dynamic "advanced_options_config" {
    for_each = var.type == "CLOUD_ARMOR" ? [1] : []
    content {
      json_parsing = var.json_parsing
      log_level    = var.log_level
    }
  }

  # ── Priority 0 ─────────────────────────────────────────────────────────────
  # CVE canary — must fire before ALL other rules, including the IP allowlist.
  # Allowlisted IPs are not exempt from CVE protection.
  dynamic "rule" {
    for_each = var.enable_cve_canary ? [1] : []
    content {
      action      = "deny(403)"
      priority    = 0
      description = "log4j CVE canary — evaluated before all other rules"
      match {
        expr {
          expression = "evaluatePreconfiguredExpr('cve-canary')"
        }
      }
    }
  }

  # ── Priorities 1–899 ────────────────────────────────────────────────────────
  # Preconfigured WAF rules (SQLi, XSS, LFI, RCE, scanner detection, etc.)
  dynamic "rule" {
    for_each = { for r in var.preconfigured_waf_rules : tostring(r.priority) => r }
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      preview     = rule.value.preview
      match {
        expr {
          expression = "evaluatePreconfiguredExpr('${rule.value.expression}')"
        }
      }
    }
  }

  # Geo-based rules (block or allow by country/region code)
  dynamic "rule" {
    for_each = { for r in var.geo_rules : tostring(r.priority) => r }
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      preview     = rule.value.preview
      match {
        expr {
          expression = "origin.region_code == '${rule.value.region_code}'"
        }
      }
    }
  }

  # Custom CEL expression rules
  dynamic "rule" {
    for_each = { for r in var.custom_rules : tostring(r.priority) => r }
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      preview     = rule.value.preview
      match {
        expr {
          expression = rule.value.expression
        }
      }
    }
  }

  # ── Priorities 900–999 ──────────────────────────────────────────────────────
  # Rate limiting / throttle rules (applied after WAF, before allowlist)
  dynamic "rule" {
    for_each = { for r in var.rate_limit_rules : tostring(r.priority) => r }
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      preview     = rule.value.preview
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value.src_ip_ranges
        }
      }
      rate_limit_options {
        conform_action   = "allow"
        exceed_action    = rule.value.exceed_action
        ban_duration_sec = rule.value.ban_duration_sec
        rate_limit_threshold {
          count        = rule.value.rate_limit_count
          interval_sec = rule.value.rate_limit_interval_sec
        }
        enforce_on_key = rule.value.enforce_on_key
      }
    }
  }

  # ── Priorities 1000+ ────────────────────────────────────────────────────────
  # IP allowlist — chunked into groups of 10 (Cloud Armor limit per rule).
  # Evaluated after WAF and rate-limit rules so that allowlisted IPs are still
  # subject to CVE canary (priority 0) and WAF scrutiny.
  dynamic "rule" {
    for_each = chunklist(sort(var.ip_allowlist), 10)
    content {
      action      = "allow"
      priority    = rule.key + 1000
      description = "Allowlisted IP range group ${rule.key + 1}"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value
        }
      }
    }
  }

  # ── Priority 2147483647 ─────────────────────────────────────────────────────
  # Default catch-all rule — deny all traffic not matched above.
  rule {
    action      = var.default_action
    priority    = 2147483647
    description = "Default rule — deny all traffic not explicitly permitted"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}
