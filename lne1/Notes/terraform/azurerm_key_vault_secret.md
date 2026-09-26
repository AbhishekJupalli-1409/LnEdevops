# azurerm_key_vault_secret

## Introduction

A named secret value stored inside Key Vault (passwords, connection strings, tokens, PEM keys).

## Why we use it

Terraform generates sensitive values; Key Vault persists them for operators and downstream automation without committing secrets to git.

## Real-life example

Labeled envelopes in the vault: “Postgres admin,” “DB URL,” “Agent SSH key.” Each envelope is an `azurerm_key_vault_secret`.

## Connections in this project

```
random_password / connection string / tls private key
  --> azurerm_key_vault_secret.*
        --> retrieved later by scripts/generate-credentials-doc.sh or operators
ACI/Postgres wiring uses values at deploy time from Terraform outputs/vars
```

## How Terraform creates it

Fixed secrets plus `for_each` extras in the keyvault module.

## In this project

Operational retrieval point for generated credentials.
