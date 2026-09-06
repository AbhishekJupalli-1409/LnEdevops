resource "tls_private_key" "agent" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_network_interface" "agent" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.agent_subnet_id
    private_ip_address_allocation = "Dynamic"
    # No public_ip_address_id: this NIC never gets a public IP. Outbound
    # internet (to register with dev.azure.com, pull kubectl/helm, etc.)
    # goes through the NAT gateway attached to snet-agent instead.
  }
}

resource "azurerm_linux_virtual_machine" "agent" {
  name                             = var.vm_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  size                             = var.vm_size
  admin_username                   = var.admin_username
  network_interface_ids            = [azurerm_network_interface.agent.id]
  disable_password_authentication  = true
  tags                             = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.agent.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Installs Azure CLI, kubectl, Helm and the Flux CLI, then registers this VM
# as an Azure Pipelines self-hosted agent - all via the run-command
# extension over ARM, so none of this needs SSH or a public IP.
resource "azurerm_virtual_machine_run_command" "install_agent" {
  name                = "install-devops-agent"
  location            = var.location
  virtual_machine_id  = azurerm_linux_virtual_machine.agent.id

  source {
    script = <<-EOT
      #!/bin/bash
      set -e
      apt-get update -y
      apt-get install -y curl unzip jq apt-transport-https lsb-release gnupg

      curl -sL https://aka.ms/InstallAzureCLIDeb | bash

      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      install -m 0755 kubectl /usr/local/bin/kubectl

      curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

      curl -s https://fluxcd.io/install.sh | bash
      mv /root/.local/bin/flux /usr/local/bin/flux 2>/dev/null || true

      mkdir -p /opt/azp-agent && cd /opt/azp-agent
      AZP_AGENT_VER=$(curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | jq -r '.tag_name' | sed 's/^v//')
      curl -o agent.tar.gz -L "https://vstsagentpackage.azureedge.net/agent/$${AZP_AGENT_VER}/vsts-agent-linux-x64-$${AZP_AGENT_VER}.tar.gz"
      tar zxvf agent.tar.gz

      export AZP_URL="${var.azp_url}"
      export AZP_TOKEN="${var.azp_token}"
      export AZP_POOL="${var.azp_pool}"
      export AZP_AGENT_NAME="vm-empapp-agent"

      ./config.sh --unattended \
        --url "$AZP_URL" \
        --auth pat \
        --token "$AZP_TOKEN" \
        --pool "$AZP_POOL" \
        --agent "$AZP_AGENT_NAME" \
        --acceptTeeEula \
        --runAsService

      ./svc.sh install
      ./svc.sh start
    EOT
  }
}
