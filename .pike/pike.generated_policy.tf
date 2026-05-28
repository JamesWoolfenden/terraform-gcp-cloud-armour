
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
