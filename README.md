# terraform-gcp-cloud-armour

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-cloud-armour/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-cloud-armour)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-cloud-armour.svg)](https://github.com/JamesWoolfenden/terraform-gcp-cloud-armour/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-cloud-armour.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-cloud-armour/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.14.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

## Usage

Add **module.cloudarmour.tf** to your code:-

```terraform
module "cloudarmour" {
  source = "JamesWoolfenden/cloud-armour/gcp"

  name = "pike"
  ip_allowlist = [
    "${module.ip.ip}/32",
  ]
}
```

Attach the resulting policy to a backend service via `policy_self_link`, and
enable `log_config { enable = true }` on that backend service — Cloud Armor
enforcement decisions are only recorded once both are wired together. See
[example/examplea](example/examplea) for a complete, deployable reference:
Cloud Armor policy (WAF rules, rate limiting, adaptive protection) fronting a
Cloud Run service via an external HTTP load balancer, with backend service
logging enabled end-to-end.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_security_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_adaptive_protection"></a> [adaptive\_protection](#input\_adaptive\_protection) | Adaptive Protection ML-based Layer 7 DDoS defence. Only effective when type = CLOUD\_ARMOR. rule\_visibility: STANDARD (attack signatures only) or PREMIUM (full request detail — requires Cloud Armor Managed Protection Plus). | <pre>object({<br/>    enable          = bool<br/>    rule_visibility = optional(string, "STANDARD")<br/>  })</pre> | <pre>{<br/>  "enable": true,<br/>  "rule_visibility": "STANDARD"<br/>}</pre> | no |
| <a name="input_custom_rules"></a> [custom\_rules](#input\_custom\_rules) | Arbitrary rules using Cloud Armor CEL expressions. Use for logic that cannot be expressed via preconfigured WAF, rate limiting, or geo rules — e.g. header-based matching, multi-country geo blocks, or composite conditions. | <pre>list(object({<br/>    priority    = number<br/>    action      = string<br/>    expression  = string<br/>    description = optional(string, "")<br/>    preview     = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | Action for the catch-all default rule at priority 2147483647. Use deny(403) for an allowlist policy (block everything unless explicitly permitted) or allow for a denylist policy. | `string` | `"deny(403)"` | no |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description for the security policy. | `string` | `""` | no |
| <a name="input_enable_cve_canary"></a> [enable\_cve\_canary](#input\_enable\_cve\_canary) | Enable the log4j/CVE canary deny rule at priority 0, evaluated before all other rules including the IP allowlist. Disable only if you are covering the same CVEs with a higher-priority custom rule. | `bool` | `true` | no |
| <a name="input_geo_rules"></a> [geo\_rules](#input\_geo\_rules) | Rules matching request origin by ISO 3166-1 alpha-2 country/region code (e.g. CN, RU, KP). Use priorities in the range 1–899 alongside WAF rules. For multi-country matching in one rule, use custom\_rules with a CEL expression such as "origin.region\_code.matches('CN\|RU')". | <pre>list(object({<br/>    priority    = number<br/>    action      = string<br/>    region_code = string<br/>    description = optional(string, "")<br/>    preview     = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_allowlist"></a> [ip\_allowlist](#input\_ip\_allowlist) | IP CIDR ranges to explicitly allow (evaluated at priority 1000+, after WAF and rate-limit rules). Pass an empty list to omit allowlist rules. | `list(string)` | `[]` | no |
| <a name="input_json_parsing"></a> [json\_parsing](#input\_json\_parsing) | JSON body parsing mode. DISABLED: no parsing. STANDARD: parse JSON bodies for WAF inspection. STANDARD\_WITH\_GRAPHQL: also parse GraphQL. Only effective when type = CLOUD\_ARMOR. | `string` | `"STANDARD"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Cloud Armor logging verbosity. NORMAL logs matched rules only. VERBOSE logs all evaluated rules — useful for tuning but increases log volume. | `string` | `"NORMAL"` | no |
| <a name="input_name"></a> [name](#input\_name) | Cloud Armor security policy name. Must be 2-63 characters, lowercase letters, digits or hyphens, starting with a letter. | `string` | n/a | yes |
| <a name="input_preconfigured_waf_rules"></a> [preconfigured\_waf\_rules](#input\_preconfigured\_waf\_rules) | Preconfigured WAF rules using evaluatePreconfiguredExpr(). Use priorities in the range 1–899 to<br/>ensure they are evaluated before the IP allowlist (1000+). Append ;sensitivity=N (1–4) to tune<br/>the detection sensitivity. Common expressions:<br/>  sqli-v33-stable           — SQL injection<br/>  xss-v33-stable            — Cross-site scripting<br/>  lfi-v33-stable            — Local file inclusion<br/>  rfi-v33-stable            — Remote file inclusion<br/>  rce-v33-stable            — Remote code execution<br/>  methodenforcement-v33-stable — HTTP method enforcement<br/>  scannerdetection-v33-stable  — Vulnerability scanner detection<br/>  protocolattack-v33-stable    — HTTP protocol attacks<br/>  sessionfixation-v33-stable   — Session fixation<br/>  cve-canary                   — Generic CVE canary (covered by enable\_cve\_canary) | <pre>list(object({<br/>    expression  = string<br/>    priority    = number<br/>    action      = optional(string, "deny(403)")<br/>    description = optional(string, "")<br/>    preview     = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_rate_limit_rules"></a> [rate\_limit\_rules](#input\_rate\_limit\_rules) | Rate limiting / throttle rules. action must be throttle (soft limit, excess requests<br/>get exceed\_action) or rate\_based\_ban (ban the client for ban\_duration\_sec after exceeding<br/>the threshold). enforce\_on\_key values: ALL, IP, HTTP\_HEADER, XFF\_IP, HTTP\_COOKIE,<br/>HTTP\_PATH, SNI, REGION\_CODE, TLS\_JA3\_FINGERPRINT, TLS\_JA4\_FINGERPRINT, USER\_IP. Use<br/>priorities in 900–999 so they fire after WAF rules but before the IP allowlist. | <pre>list(object({<br/>    priority                = number<br/>    description             = optional(string, "")<br/>    src_ip_ranges           = optional(list(string), ["*"])<br/>    action                  = optional(string, "throttle")<br/>    exceed_action           = optional(string, "deny(429)")<br/>    rate_limit_count        = number<br/>    rate_limit_interval_sec = number<br/>    enforce_on_key          = optional(string, "IP")<br/>    ban_duration_sec        = optional(number, null)<br/>    preview                 = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_type"></a> [type](#input\_type) | Security policy type. CLOUD\_ARMOR (global external ALB, full feature set), CLOUD\_ARMOR\_EDGE (Cloud CDN / Media CDN), or CLOUD\_ARMOR\_NETWORK (advanced network DDoS for network LBs). Adaptive protection and advanced\_options\_config are only available for CLOUD\_ARMOR. | `string` | `"CLOUD_ARMOR"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_policy"></a> [policy](#output\_policy) | The Cloud Armor security policy resource. Attach it to a backend service via google\_compute\_backend\_service.security\_policy = google\_compute\_security\_policy.default.self\_link. |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | Name of the Cloud Armor security policy. |
| <a name="output_policy_self_link"></a> [policy\_self\_link](#output\_policy\_self\_link) | Self-link of the Cloud Armor security policy, for use in google\_compute\_backend\_service.security\_policy. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Information

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "compute.securityPolicies.create",
    "compute.securityPolicies.delete",
    "compute.securityPolicies.get",
    "compute.securityPolicies.update"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "compute.securityPolicies.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Related Projects

Check out these related projects.

- [terraform-aws-codecommit](https://github.com/jameswoolfenden/terraform-aws-codebuild) - Storing ones code

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-aws-bigquery/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-aws-bigquery/issues) to report any bugs or file feature requests.

## Copyrights

Copyright � 2023-26 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
