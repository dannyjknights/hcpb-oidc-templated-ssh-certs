resource "boundary_managed_group" "oidc_managed_group" {
  name           = "okta-managed-group"
  description    = "Okta Managed Group"
  auth_method_id = boundary_auth_method_oidc.provider.id
  filter         = "\"okta.com\" in \"/token/iss\""
}

//The below grant_strings are set to allow all for this basic example
resource "boundary_role" "oidc_admin_role" {
  name          = "Admin Role"
  description   = "admin role"
  principal_ids = [boundary_managed_group.oidc_managed_group.id]
  grant_strings = ["ids=*;type=*;actions=*"]
  scope_id      = boundary_scope.global.id
}


resource "boundary_role" "oidc_user_role" {
  name          = "User Role"
  description   = "user role"
  principal_ids = [boundary_managed_group.oidc_managed_group.id]
  grant_strings = ["ids=*;type=*;actions=*"]
  scope_id      = boundary_scope.org.id
}

resource "boundary_role" "oidc_project_role" {
  name          = "project-role"
  description   = "Project Role"
  principal_ids = [boundary_managed_group.oidc_managed_group.id]
  grant_strings = ["ids=*;type=*;actions=*"]
  scope_id      = boundary_scope.project.id
}

