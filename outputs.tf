output "vnet_peer_0_id" {
  description = "The id of the newly created virtual network peering in on first virtual netowork. "
  value       = azurerm_virtual_network_peering.vnet_peer_0.id
}

output "vnet_peer_1_id" {
  description = "The id of the newly created virtual network peering in on second virtual netowork. "
  value       = azurerm_virtual_network_peering.vnet_peer_1.id
}
