//Create a periodic, orphan token for Boundary with the attached policies
resource "vault_token" "boundary_vault_token" {
  display_name = "boundary-token"
  policies     = ["boundary-controller", "ssh-policy", "policy-database"]
  no_parent    = true
  renewable    = true
  ttl          = "24h"
  period       = "24h"
}

//Credential store for Vault
resource "boundary_credential_store_vault" "vault_cred_store" {
  name        = "boundary-vault-credential-store"
  description = "Vault Credential Store"
  address     = var.vault_addr
  token       = vault_token.boundary_vault_token.client_token
  namespace   = "admin"
  scope_id    = boundary_scope.project.id
  depends_on  = [vault_token.boundary_vault_token]
}

/*Credential library for SSH injected credentials. The name that will be attached to the SSH certificate will
be the email address you use to authenticate into Okta, but will have everything after and including, the '@'
sign removed. 
*/
resource "boundary_credential_library_vault_ssh_certificate" "vault_ssh_cert" {
  name                = "ssh-certs"
  description         = "Vault SSH Cert Library"
  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
  path                = "ssh-client-signer/sign/boundary-client"
  username            = "{{truncateFrom .User.Email \"@\"}}"
}
