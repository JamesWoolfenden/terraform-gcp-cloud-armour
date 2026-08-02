variable "name" {
  type        = string
  description = "Cloud Armor security policy name. Must be 2-63 characters, lowercase letters, digits or hyphens, starting with a letter."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.name))
    error_message = "name must be 2-63 characters, start with a lowercase letter, end with a letter or digit, and contain only lowercase letters, digits or hyphens."
  }
}

variable "description" {
  type        = string
  description = "Human-readable description for the security policy."
  default     = ""

  validation {
    condition     = length(var.description) <= 2048
    error_message = "description must be 2048 characters or fewer."
  }
}

variable "type" {
  type        = string
  description = "Security policy type. CLOUD_ARMOR (global external ALB, full feature set), CLOUD_ARMOR_EDGE (Cloud CDN / Media CDN), or CLOUD_ARMOR_NETWORK (advanced network DDoS for network LBs). Adaptive protection and advanced_options_config are only available for CLOUD_ARMOR."
  default     = "CLOUD_ARMOR"

  validation {
    condition     = contains(["CLOUD_ARMOR", "CLOUD_ARMOR_EDGE", "CLOUD_ARMOR_NETWORK"], var.type)
    error_message = "type must be one of CLOUD_ARMOR, CLOUD_ARMOR_EDGE, or CLOUD_ARMOR_NETWORK."
  }
}

variable "default_action" {
  type        = string
  description = "Action for the catch-all default rule at priority 2147483647. Use deny(403) for an allowlist policy (block everything unless explicitly permitted) or allow for a denylist policy."
  default     = "deny(403)"

  validation {
    condition     = contains(["deny(403)", "deny(404)", "deny(429)", "deny(502)", "allow"], var.default_action)
    error_message = "default_action must be one of: deny(403), deny(404), deny(429), deny(502), allow."
  }
}

variable "ip_allowlist" {
  type        = list(string)
  description = "IP CIDR ranges to explicitly allow (evaluated at priority 1000+, after WAF and rate-limit rules). Pass an empty list to omit allowlist rules."
  default     = []

  validation {
    condition     = alltrue([for ip in var.ip_allowlist : can(cidrhost(ip, 0))])
    error_message = "All entries in ip_allowlist must be valid CIDR blocks, e.g. \"203.0.113.0/24\" or \"198.51.100.1/32\"."
  }
}

variable "enable_cve_canary" {
  type        = bool
  description = "Enable the log4j/CVE canary deny rule at priority 0, evaluated before all other rules including the IP allowlist. Disable only if you are covering the same CVEs with a higher-priority custom rule."
  default     = true
}

variable "adaptive_protection" {
  type = object({
    enable          = bool
    rule_visibility = optional(string, "STANDARD")
  })
  description = "Adaptive Protection ML-based Layer 7 DDoS defence. Only effective when type = CLOUD_ARMOR. rule_visibility: STANDARD (attack signatures only) or PREMIUM (full request detail — requires Cloud Armor Managed Protection Plus)."
  default = {
    enable          = true
    rule_visibility = "STANDARD"
  }

  validation {
    condition     = contains(["STANDARD", "PREMIUM"], var.adaptive_protection.rule_visibility)
    error_message = "adaptive_protection.rule_visibility must be STANDARD or PREMIUM."
  }
}

variable "json_parsing" {
  type        = string
  description = "JSON body parsing mode. DISABLED: no parsing. STANDARD: parse JSON bodies for WAF inspection. STANDARD_WITH_GRAPHQL: also parse GraphQL. Only effective when type = CLOUD_ARMOR."
  default     = "STANDARD"

  validation {
    condition     = contains(["DISABLED", "STANDARD", "STANDARD_WITH_GRAPHQL"], var.json_parsing)
    error_message = "json_parsing must be one of: DISABLED, STANDARD, STANDARD_WITH_GRAPHQL."
  }
}

variable "log_level" {
  type        = string
  description = "Cloud Armor logging verbosity. NORMAL logs matched rules only. VERBOSE logs all evaluated rules — useful for tuning but increases log volume."
  default     = "NORMAL"

  validation {
    condition     = contains(["NORMAL", "VERBOSE"], var.log_level)
    error_message = "log_level must be NORMAL or VERBOSE."
  }
}

variable "preconfigured_waf_rules" {
  type = list(object({
    expression  = string
    priority    = number
    action      = optional(string, "deny(403)")
    description = optional(string, "")
    preview     = optional(bool, false)
  }))
  description = <<-EOT
    Preconfigured WAF rules using evaluatePreconfiguredExpr(). Use priorities in the range 1–899 to
    ensure they are evaluated before the IP allowlist (1000+). Append ;sensitivity=N (1–4) to tune
    the detection sensitivity. Common expressions:
      sqli-v33-stable           — SQL injection
      xss-v33-stable            — Cross-site scripting
      lfi-v33-stable            — Local file inclusion
      rfi-v33-stable            — Remote file inclusion
      rce-v33-stable            — Remote code execution
      methodenforcement-v33-stable — HTTP method enforcement
      scannerdetection-v33-stable  — Vulnerability scanner detection
      protocolattack-v33-stable    — HTTP protocol attacks
      sessionfixation-v33-stable   — Session fixation
      cve-canary                   — Generic CVE canary (covered by enable_cve_canary)
  EOT
  default     = []

  validation {
    condition     = alltrue([for r in var.preconfigured_waf_rules : r.priority >= 1 && r.priority <= 2147483646])
    error_message = "All preconfigured_waf_rules must have priority between 1 and 2147483646."
  }
}

variable "rate_limit_rules" {
  type = list(object({
    priority                = number
    description             = optional(string, "")
    src_ip_ranges           = optional(list(string), ["*"])
    action                  = optional(string, "throttle")
    exceed_action           = optional(string, "deny(429)")
    rate_limit_count        = number
    rate_limit_interval_sec = number
    enforce_on_key          = optional(string, "IP")
    ban_duration_sec        = optional(number, null)
    preview                 = optional(bool, false)
  }))
  description = <<-EOT
    Rate limiting / throttle rules. action must be throttle (soft limit, excess requests
    get exceed_action) or rate_based_ban (ban the client for ban_duration_sec after exceeding
    the threshold). enforce_on_key values: ALL, IP, HTTP_HEADER, XFF_IP, HTTP_COOKIE,
    HTTP_PATH, SNI, REGION_CODE, TLS_JA3_FINGERPRINT, TLS_JA4_FINGERPRINT, USER_IP. Use
    priorities in 900–999 so they fire after WAF rules but before the IP allowlist.
  EOT
  default     = []

  validation {
    condition     = alltrue([for r in var.rate_limit_rules : contains(["throttle", "rate_based_ban"], r.action)])
    error_message = "All rate_limit_rules must have action of throttle or rate_based_ban."
  }

  validation {
    condition     = alltrue([for r in var.rate_limit_rules : r.priority >= 1 && r.priority <= 2147483646])
    error_message = "All rate_limit_rules must have priority between 1 and 2147483646."
  }

  validation {
    condition     = alltrue([for r in var.rate_limit_rules : contains(["ALL", "IP", "HTTP_HEADER", "XFF_IP", "HTTP_COOKIE", "HTTP_PATH", "SNI", "REGION_CODE", "TLS_JA3_FINGERPRINT", "TLS_JA4_FINGERPRINT", "USER_IP"], r.enforce_on_key)])
    error_message = "All rate_limit_rules must have a valid enforce_on_key: ALL, IP, HTTP_HEADER, XFF_IP, HTTP_COOKIE, HTTP_PATH, SNI, REGION_CODE, TLS_JA3_FINGERPRINT, TLS_JA4_FINGERPRINT, or USER_IP."
  }
}

variable "geo_rules" {
  type = list(object({
    priority    = number
    action      = string
    region_code = string
    description = optional(string, "")
    preview     = optional(bool, false)
  }))
  description = "Rules matching request origin by ISO 3166-1 alpha-2 country/region code (e.g. CN, RU, KP). Use priorities in the range 1–899 alongside WAF rules. For multi-country matching in one rule, use custom_rules with a CEL expression such as \"origin.region_code.matches('CN|RU')\"."
  default     = []

  validation {
    condition     = alltrue([for r in var.geo_rules : contains(["deny(403)", "deny(404)", "deny(429)", "deny(502)", "allow"], r.action)])
    error_message = "All geo_rules must have a valid action: deny(403), deny(404), deny(429), deny(502), or allow."
  }

  validation {
    condition     = alltrue([for r in var.geo_rules : r.priority >= 1 && r.priority <= 2147483646])
    error_message = "All geo_rules must have priority between 1 and 2147483646."
  }
}

variable "custom_rules" {
  type = list(object({
    priority    = number
    action      = string
    expression  = string
    description = optional(string, "")
    preview     = optional(bool, false)
  }))
  description = "Arbitrary rules using Cloud Armor CEL expressions. Use for logic that cannot be expressed via preconfigured WAF, rate limiting, or geo rules — e.g. header-based matching, multi-country geo blocks, or composite conditions."
  default     = []

  validation {
    condition     = alltrue([for r in var.custom_rules : contains(["deny(403)", "deny(404)", "deny(429)", "deny(502)", "allow", "redirect", "throttle", "rate_based_ban"], r.action)])
    error_message = "All custom_rules must have a valid action."
  }

  validation {
    condition     = alltrue([for r in var.custom_rules : r.priority >= 1 && r.priority <= 2147483646])
    error_message = "All custom_rules must have priority between 1 and 2147483646."
  }
}
