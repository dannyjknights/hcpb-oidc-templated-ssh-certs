resource "boundary_auth_method_oidc" "provider" {
  name                 = "Okta"
  description          = "OIDC auth method for Okta"
  scope_id             = "global"
  issuer               = var.okta_issuer
  client_id            = var.okta_client_id
  client_secret        = var.okta_client_secret
  claims_scopes        = ["email"]
  signing_algorithms   = ["RS256"]
  api_url_prefix       = var.boundary_addr
  is_primary_for_scope = true
  state                = "active-public"
  max_age              = 0
}

resource "boundary_account_oidc" "oidc_user" {
  name           = "boundary-oidc-account"
  description    = "OIDC account"
  auth_method_id = boundary_auth_method_oidc.provider.id
  issuer         = var.okta_issuer
  subject        = var.okta_client_id
}