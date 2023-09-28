module "CloudArmour" {
  source = "../../"
  cloudarmour_rule_ips = [
  "${module.ip.ip}/32", ]
  cloudarmour_rule_name = "pike"
}
module "ip" {
  source = "git::https://github.com/JamesWoolfenden/terraform-http-ip.git?ref=6e651695dc636de858961f36bc54ffe9e744e946"
}
