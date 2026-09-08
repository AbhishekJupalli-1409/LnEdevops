# azurerm_virtual_machine_run_command

## Brief introduction

Runs a script on a VM via the Azure VM agent (no SSH session required from your laptop).

## Why we create it

Automate installing Azure CLI, kubectl, helm, flux, and registering the Azure DevOps agent at provision time.

## How Terraform creates it

```hcl
resource "azurerm_virtual_machine_run_command" "install_agent" {
  name               = "install-azdo-agent"
  location           = var.location
  virtual_machine_id = azurerm_linux_virtual_machine.agent.id
  source {
    script = <<-EOF
      # install tools + configure azp agent with PAT
    EOF
  }
}
```

## Use in this project

Hands-free agent bootstrap after the VM exists.

## Example to understand

Remote “setup checklist” Azure runs on the new machine so you don’t SSH in to install everything manually.
