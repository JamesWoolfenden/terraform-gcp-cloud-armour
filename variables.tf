

variable "cloudarmour_rule_name" {
  type        = string
  description = "CloudArmour rule name"
}

variable "cloudarmour_rule_ips" {
  type        = list(any)
  description = "CloudArmour rule IP addresses"
}
