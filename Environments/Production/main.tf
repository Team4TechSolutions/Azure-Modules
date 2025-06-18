provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

############################################
# Resource Group
############################################

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

############################################
# Networking Module
############################################

module "network" {
  source              = "../../Azure-modules/Network"
  vnet_name           = "prod-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  vnet_address_space       = ["10.0.0.0/16"]
  public_subnet_prefixes   = ["10.0.1.0/24"]
  private_subnet_prefixes  = ["10.0.2.0/24"]
  tags                     = var.tags
}

############################################
# Bastion Host Module
############################################

module "bastion" {
  source              = "../../Azure-modules/Bastion-hosts"
  bastion_name        = "prod-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.network.public_subnet_ids[0] # Must be named AzureBastionSubnet
  tags                = var.tags
}

############################################
# Windows VM Modules
############################################

module "windows_vm_1" {
  source                = "../../Azure-modules/Virtual-Machines"
  instance_name         = "vm01"
  location              = var.location
  resource_group_name   = azurerm_resource_group.main.name
  instance_subnet_id    = module.network.private_subnet_ids[0]
  instance_type         = "Standard_D2s_v3"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  image_sku             = "2022-Datacenter"
  root_volume_size      = 128
  root_volume_type      = "Standard_LRS"
  tags                  = var.tags
}

module "windows_vm_2" {
  source                = "../../Azure-modules/Virtual-Machines"
  instance_name         = "vm02"
  location              = var.location
  resource_group_name   = azurerm_resource_group.main.name
  instance_subnet_id    = module.network.private_subnet_ids[0]
  instance_type         = "Standard_D2s_v3"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  image_sku             = "2022-Datacenter"
  root_volume_size      = 128
  root_volume_type      = "Standard_LRS"
  tags                  = var.tags
}



<a
  href={downloadUrl}
  target="_blank"
  rel="noopener noreferrer"
  className="mt-2 inline-block text-green-700 underline"
>
  :inbox_tray: Download Excel
</a>





12:46
{status === ':hourglass_flowing_sand: Uploading and processing...' && (
  <div className="mt-4 animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600 mx-auto"></div>
