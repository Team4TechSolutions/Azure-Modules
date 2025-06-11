
#----------------------
# Outputs
#----------------------
output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "public_subnet_ids" {
  value = [for s in azurerm_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in azurerm_subnet.private : s.id]
}
