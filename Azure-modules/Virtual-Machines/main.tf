########################################
# Azure Windows VM Module (Production Style)
########################################

resource "azurerm_network_interface" "nic" {
  name                = "${var.instance_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.instance_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge({
    Name = var.instance_name
  }, var.tags)
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.instance_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.instance_type

  admin_username = var.admin_username
  admin_password = var.admin_password

  os_disk {
    name                 = "${var.instance_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.root_volume_type
    disk_size_gb         = var.root_volume_size
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.image_sku
    version   = "latest"
  }

  provision_vm_agent        = true
  enable_automatic_updates  = true

  tags = merge({
    Name = var.instance_name
  }, var.tags)
}