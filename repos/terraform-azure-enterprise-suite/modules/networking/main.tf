# ------------------------------------------------------------------------------
# Azure Virtual Network & Subnets (Modular Architecture)
# ------------------------------------------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null

  tags = var.tags
}

# Subnets dynamically constructed from map of objects
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  # Dynamic delegation block for services like AKS, App Services, or Container Apps
  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Network Security Group (NSG) with Dynamic Security Rules
# ------------------------------------------------------------------------------

resource "azurerm_network_security_group" "nsg" {
  count               = length(var.nsg_rules) > 0 ? 1 : 0
  name                = "${var.vnet_name}-default-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Dynamic block iterating through parameterized rule definitions
  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                         = security_rule.key
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      source_port_ranges           = security_rule.value.source_port_ranges
      destination_port_range       = security_rule.value.destination_port_range
      destination_port_ranges      = security_rule.value.destination_port_ranges
      source_address_prefix        = security_rule.value.source_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefix   = security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes
      description                  = security_rule.value.description
    }
  }

  tags = var.tags
}

# Associate NSG with eligible subnets (excluding Gateway and AzureFirewall subnets)
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = {
    for k, v in azurerm_subnet.subnets : k => v.id
    if !can(regex("GatewaySubnet|AzureFirewallSubnet|AzureBastionSubnet", k)) && length(var.nsg_rules) > 0
  }

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.nsg[0].id
}

# ------------------------------------------------------------------------------
# Route Table with Dynamic Custom Routes (UDR)
# ------------------------------------------------------------------------------

resource "azurerm_route_table" "route_table" {
  count               = length(var.custom_routes) > 0 ? 1 : 0
  name                = "${var.vnet_name}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "route" {
    for_each = var.custom_routes
    content {
      name                   = route.key
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  tags = var.tags
}

# Associate Route Table with spokes (excluding dedicated infra subnets)
resource "azurerm_subnet_route_table_association" "rt_assoc" {
  for_each = {
    for k, v in azurerm_subnet.subnets : k => v.id
    if !can(regex("GatewaySubnet|AzureFirewallSubnet|AzureBastionSubnet", k)) && length(var.custom_routes) > 0
  }

  subnet_id      = each.value
  route_table_id = azurerm_route_table.route_table[0].id
}

