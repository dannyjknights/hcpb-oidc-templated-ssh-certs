resource "vault_policy" "boundary_controller_policy" {
  name   = "boundary-controller"
  policy = <<EOT
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}

path "sys/capabilities-self" {
  capabilities = ["update"]
}
EOT
}

resource "vault_policy" "ssh-policy" {
  name   = "ssh-policy"
  policy = <<EOT
  path "ssh-client-signer/issue/boundary-client" {
  capabilities = ["create", "update"]
}

path "ssh-client-signer/sign/boundary-client" {
  capabilities = ["create", "update"]
}
EOT
}