//En este fichero se definen las variables de salida a utilizar

output "rg-id" {
  value = azurerm_resource_group.rg.id
}

output "rg-name" {
  value = azurerm_resource_group.rg.name
}

