//En este fichero se definen las variables de salida a utilizar

output "rg-id" {
  value = azurerm_resource_group.rg.id
}

output "rg-name" {
  value = azurerm_resource_group.rg.name
}

output "acr-username" {
  value = azurerm_container_registry.acr.admin_username
  sensitive = true
}

output "acr-password" {
  value = azurerm_container_registry.acr.admin_password
  sensitive = true
}

output "acr-loginServer" {
  value = azurerm_container_registry.acr.login_server
}

output "vmPodmanPublicIP" {
  value = azurerm_public_ip.podmanPublicIP.ip_address
}