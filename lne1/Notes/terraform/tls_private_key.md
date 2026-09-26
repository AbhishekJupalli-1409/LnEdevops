# tls_private_key

## Introduction

The TLS provider can generate SSH or TLS key pairs in Terraform. For Linux VMs, the **public** key is placed in `authorized_keys`; the **private** key is kept secret (often Key Vault).

## Why we use it

The agent VM needs an admin SSH key. Generating it in Terraform avoids humans emailing keys around. Storing the private key in Key Vault supports break-glass SSH if needed.

## Real-life example

Cutting a new **house key** at provision time: public half filed in the lock (VM), private half locked in the office safe (Key Vault).

## Connections in this project

```
tls_private_key.agent
  public_key_openssh --> azurerm_linux_virtual_machine.agent admin SSH
  private_key_pem    --> Key Vault secret (extra secrets)
```

Day-to-day agent setup uses VM Run Command + PAT for AzDO registration — SSH is for emergency access, not routine pipeline work.

## How Terraform creates it

```hcl
resource "tls_private_key" "agent" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
```

## In this project

Part of `terraform/modules/agent-vm`.
