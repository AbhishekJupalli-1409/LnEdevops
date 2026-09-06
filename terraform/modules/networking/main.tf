resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# --- Subnets ------------------------------------------------------------------

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aks_subnet_cidr]
}

resource "azurerm_subnet" "aci" {
  name                 = "snet-aci"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aci_subnet_cidr]

  delegation {
    name = "aci-delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Delegated subnet for PostgreSQL Flexible Server "Private access (VNet
# integration)". This is deliberately used INSTEAD OF the separate Private
# Link/Private Endpoint feature: Flexible Server only supports Private
# Endpoint on servers created in *public-access* mode, which would put a
# public entry point in front of the database. VNet integration keeps 100%
# of backend<->database traffic inside the VNet with no public path at all,
# which is the stronger interpretation of "communication ... over a private
# endpoint" for this database. See docs/ARCHITECTURE_NOTES.md.
resource "azurerm_subnet" "postgres" {
  name                 = "snet-postgres"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.postgres_subnet_cidr]

  delegation {
    name = "postgres-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Subnet reserved for genuine Azure Private Endpoints (Key Vault today;
# anything Premium-tier ACR gets upgraded to later would also land here).
resource "azurerm_subnet" "pe" {
  name                 = "snet-pe"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.pe_subnet_cidr]
}

# Subnet for the private self-hosted DevOps agent VM. Outbound-only via a
# NAT gateway (its own public IP - a NAT Gateway is not a NIC, so this does
# not conflict with the "no public IPs on NICs" policy). The VM's own NIC
# never gets a public IP.
resource "azurerm_subnet" "agent" {
  name                 = "snet-agent"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.agent_subnet_cidr]
}

resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-agent"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "agent" {
  name                = "nat-agent"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "agent" {
  nat_gateway_id       = azurerm_nat_gateway.agent.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "agent" {
  subnet_id      = azurerm_subnet.agent.id
  nat_gateway_id = azurerm_nat_gateway.agent.id
}

# --- NSGs -----------------------------------------------------------------

resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  # No custom rules: AKS/Azure LB manage the rules this NSG needs for
  # LoadBalancer services (e.g. the ingress-nginx public IP) automatically.
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

resource "azurerm_network_security_group" "aci" {
  name                = "nsg-aci"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Only the AKS subnet (where the frontend runs) may reach the backend port.
resource "azurerm_network_security_rule" "aci_allow_from_aks" {
  name                        = "allow-aks-to-backend"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.backend_port
  source_address_prefix       = var.aks_subnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aci.name
}

resource "azurerm_network_security_rule" "aci_deny_all_other_inbound" {
  name                        = "deny-all-other-inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aci.name
}

resource "azurerm_subnet_network_security_group_association" "aci" {
  subnet_id                 = azurerm_subnet.aci.id
  network_security_group_id = azurerm_network_security_group.aci.id
}

# --- Private DNS zones ------------------------------------------------------

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "vnet-link-postgres"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "vnet-link-keyvault"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = var.tags
}
