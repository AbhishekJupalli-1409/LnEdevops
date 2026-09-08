# tls_private_key

## Brief introduction

Generates an SSH key pair (private + public) using the TLS provider.

## Why we create it

Linux VM admin login needs an SSH public key. Private key can be stored in Key Vault for break-glass access.

## How Terraform creates it

```hcl
resource "tls_private_key" "agent" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
```

Public key goes to the VM; private key often as a Key Vault secret.

## Use in this project

SSH key material for the private DevOps agent VM (`terraform/modules/agent-vm`).

## Example to understand

Terraform cuts a new house key: public half goes in the lock (VM), private half goes in the safe (Key Vault).
