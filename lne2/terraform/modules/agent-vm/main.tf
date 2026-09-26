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
  }
}

resource "azurerm_linux_virtual_machine" "agent" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  network_interface_ids           = [azurerm_network_interface.agent.id]
  disable_password_authentication = true
  tags                            = var.tags

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

resource "azurerm_virtual_machine_run_command" "install_agent" {
  name               = "install-devops-agent"
  location           = var.location
  virtual_machine_id = azurerm_linux_virtual_machine.agent.id
  tags               = var.tags

  source {
    script = <<-EOT
      #!/bin/bash
      set -euo pipefail
      export DEBIAN_FRONTEND=noninteractive
      export NEEDRESTART_MODE=a

      AGENT_USER="${var.admin_username}"
      AGENT_HOME="/opt/azp-agent"

      apt-get update -y
      apt-get install -y curl unzip jq apt-transport-https ca-certificates gnupg lsb-release

      if ! command -v az >/dev/null 2>&1; then
        curl -sL https://aka.ms/InstallAzureCLIDeb | bash
      fi

      if ! command -v kubectl >/dev/null 2>&1; then
        curl -fLO "https://dl.k8s.io/release/$(curl -fL -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        install -m 0755 kubectl /usr/local/bin/kubectl
        rm -f kubectl
      fi

      if ! command -v helm >/dev/null 2>&1; then
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
      fi

      if ! command -v flux >/dev/null 2>&1; then
        curl -fsSL https://fluxcd.io/install.sh | bash
        mv /root/.local/bin/flux /usr/local/bin/flux 2>/dev/null || true
      fi

      mkdir -p "$${AGENT_HOME}"
      cd "$${AGENT_HOME}"

      if [ ! -x ./config.sh ]; then
        AZP_AGENT_VER=$(curl -fsSL https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | jq -r '.tag_name' | sed 's/^v//')
        AGENT_TAR="vsts-agent-linux-x64-$${AZP_AGENT_VER}.tar.gz"
        if ! curl -fL --retry 3 -o agent.tar.gz "https://download.agent.dev.azure.com/agent/$${AZP_AGENT_VER}/$${AGENT_TAR}"; then
          curl -fL --retry 3 -o agent.tar.gz "https://github.com/microsoft/azure-pipelines-agent/releases/download/v$${AZP_AGENT_VER}/$${AGENT_TAR}"
        fi
        tar zxvf agent.tar.gz
        rm -f agent.tar.gz
      fi

      chown -R "$${AGENT_USER}:$${AGENT_USER}" "$${AGENT_HOME}"

      if [ ! -f .agent ]; then
        AZP_TOKEN=$(printf '%s' '${base64encode(var.azp_token)}' | base64 -d)
        if [ -z "$${AZP_TOKEN}" ]; then
          echo "azp_token is empty. Set secret azdoPersonalAccessToken in voteapp-shared-vars." >&2
          exit 1
        fi
        runuser -u "$${AGENT_USER}" -- ./config.sh --unattended \
          --url "${var.azp_url}" \
          --auth pat \
          --token "$${AZP_TOKEN}" \
          --pool "${var.azp_pool}" \
          --agent "${var.vm_name}" \
          --work _work \
          --acceptTeeEula
      fi

      ./svc.sh install "$${AGENT_USER}" || true
      ./svc.sh start || true
    EOT
  }
}
