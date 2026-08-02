# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
# holden:ignore:HLD_TF_065: for example only, not production
module "CloudArmour" {
  source = "../../"

  name        = "pike"
  description = "Example Cloud Armor policy — allowlist + WAF + rate limiting"

  ip_allowlist = [
    "${module.ip.ip}/32",
  ]

  # Preconfigured WAF rules — evaluated at priorities 100–500
  preconfigured_waf_rules = [
    {
      expression  = "sqli-v33-stable"
      priority    = 100
      description = "Block SQL injection attacks"
    },
    {
      expression  = "xss-v33-stable"
      priority    = 200
      description = "Block cross-site scripting attacks"
    },
    {
      expression  = "lfi-v33-stable"
      priority    = 300
      description = "Block local file inclusion attacks"
    },
    {
      expression  = "rce-v33-stable"
      priority    = 400
      description = "Block remote code execution attacks"
    },
    {
      expression  = "scannerdetection-v33-stable"
      priority    = 500
      description = "Block vulnerability scanner traffic"
    },
  ]

  # Rate limiting — throttle abusive IPs before they hit the allowlist
  rate_limit_rules = [
    {
      priority                = 900
      description             = "Throttle high-volume IPs to 100 requests per 10 seconds"
      rate_limit_count        = 100
      rate_limit_interval_sec = 10
      enforce_on_key          = "IP"
      exceed_action           = "deny(429)"
    },
  ]

  # Adaptive protection (ML-based DDoS — on by default)
  adaptive_protection = {
    enable          = true
    rule_visibility = "STANDARD"
  }

  json_parsing = "STANDARD"
  log_level    = "VERBOSE"
}

# holden:ignore:HLD_TF_065: by design
module "ip" {
  source = "git::https://github.com/JamesWoolfenden/terraform-http-ip.git?ref=2f3cef24e667fb840a3d3481f5a1aaa5a1ac7d28&depth=1" #v0.3.14
}
