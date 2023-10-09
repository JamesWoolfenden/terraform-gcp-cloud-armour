# terraform-gcp-cloud-armour

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-cloud-armour/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-cloud-armour)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-cloud-armour.svg)](https://github.com/JamesWoolfenden/terraform-gcp-cloud-armour/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-cloud-armour.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-cloud-armour/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.14.0-blue.svg)
[![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/JamesWoolfenden/terraform-gcp-cloud-armour/cis_aws)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=JamesWoolfenden%2Fterraform-gcp-cloud-armour&benchmark=CIS+AWS+V1.2)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![checkov](https://img.shields.io/badge/checkov-verified-brightgreen)](https://www.checkov.io/)
[![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/jameswoolfenden/terraform-gcp-cloud-armour/general)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=JamesWoolfenden%2Fterraform-gcp-cloud-armour&benchmark=INFRASTRUCTURE+SECURITY)

## Usage

Add **module.art.tf** to your code:-

```terraform
module "cloudarnour" {
  source             = "JamesWoolfenden/cloud-armour/gcp"
  cloudarmour_rule_ips = [
  "${module.ip.ip}/32", ]
  cloudarmour_rule_name = "pike"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_security_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudarmour_rule_ips"></a> [cloudarmour\_rule\_ips](#input\_cloudarmour\_rule\_ips) | CloudArmour rule IP addresses | `list(any)` | n/a | yes |
| <a name="input_cloudarmour_rule_name"></a> [cloudarmour\_rule\_name](#input\_cloudarmour\_rule\_name) | CloudArmour rule name | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Information

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang

resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike"
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

Copyright � 2023 James Woolfenden

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
