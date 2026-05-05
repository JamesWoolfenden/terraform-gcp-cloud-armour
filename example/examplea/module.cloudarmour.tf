module "CloudArmour" {
  source = "../../"
  cloudarmour_rule_ips = [
  "${module.ip.ip}/32", ]
  cloudarmour_rule_name = "pike"
}
module "ip" {
  source = "git::https://github.com/JamesWoolfenden/terraform-http-ip.git?ref=2f3cef24e667fb840a3d3481f5a1aaa5a1ac7d28" #v0.3.14
}
