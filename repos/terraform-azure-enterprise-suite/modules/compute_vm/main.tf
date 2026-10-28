# ------------------------------------------------------------------------------
# Production Linux Virtual Machines (Modular & Dynamic)
# ------------------------------------------------------------------------------

resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = each.value.private_ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = each.value.private_ip_address
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vms

  name                  = each.key
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = each.value.vm_size
  admin_username        = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  custom_data           = each.value.custom_data != null ? base64encode(each.value.custom_data) : null

  # Dynamic Admin SSH Key Block
  dynamic "admin_ssh_key" {
    for_each = each.value.ssh_public_key != "" ? [1] : []
    content {
      username   = each.value.admin_username
      public_key = each.value.ssh_public_key
    }
  }

  os_disk {
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_storage_type
    disk_size_gb         = each.value.os_disk_size_gb
  }

  source_image_reference {
    publisher = each.value.image_publisher
    offer     = each.value.image_offer
    sku       = each.value.image_sku
    version   = each.value.image_version
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

