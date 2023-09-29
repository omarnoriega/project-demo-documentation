# Define el proveedor de Azure
provider "azurerm" {
  features {}
}

# Crea un grupo de recursos de Azure
resource "azurerm_resource_group" "my_resource_group" {
  name     = "my-resource-group"  # Cambia esto a un nombre único
  location = "East US"  # Cambia esto a tu región preferida
}

# Crea un almacenamiento de blobs de Azure para archivos estáticos
resource "azurerm_storage_account" "static_files_storage" {
  name                     = "mystaticfilesstorage"  # Cambia esto a un nombre único
  resource_group_name      = azurerm_resource_group.my_resource_group.name
  location                 = azurerm_resource_group.my_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Crea un contenedor en el almacenamiento de blobs
resource "azurerm_storage_container" "static_files_container" {
  name                  = "staticfiles"
  storage_account_name  = azurerm_storage_account.static_files_storage.name
  container_access_type = "blob"
}

# Crea una función de Azure
resource "azurerm_function_app" "my_function_app" {
  name                      = "myfunctionapp"  # Cambia esto a un nombre único
  location                  = azurerm_resource_group.my_resource_group.location
  resource_group_name       = azurerm_resource_group.my_resource_group.name
  app_service_plan_id        = azurerm_app_service_plan.my_app_service_plan.id
  storage_account_name       = azurerm_storage_account.static_files_storage.name
  storage_account_access_key = azurerm_storage_account.static_files_storage.primary_access_key
}

# Crea un plan de servicios de aplicaciones de Azure
resource "azurerm_app_service_plan" "my_app_service_plan" {
  name                = "myappserviceplan"  # Cambia esto a un nombre único
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Crea un servicio de Azure CDN para la distribución de contenido estático
resource "azurerm_cdn_profile" "my_cdn_profile" {
  name     = "mycdnprofile"  # Cambia esto a un nombre único
  location = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  sku {
    name     = "Standard_Akamai"
    tier     = "Standard"
  }
}

resource "azurerm_cdn_endpoint" "my_cdn_endpoint" {
  name                = "mycdnendpoint"  # Cambia esto a un nombre único
  profile_name        = azurerm_cdn_profile.my_cdn_profile.name
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  origin {
    name      = azurerm_storage_account.static_files_storage.name
    host_name = azurerm_storage_account.static_files_storage.primary_blob_endpoint
  }
}

# Crea una API Management de Azure para exponer la función como una API Gateway
resource "azurerm_api_management" "my_api_management" {
  name                = "myapimanagement"  # Cambia esto a un nombre único
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  publisher_name      = "My Company"
  publisher_email     = "contact@mycompany.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_api" "my_api" {
  name                = "myapi"  # Cambia esto a un nombre único
  resource_group_name = azurerm_resource_group.my_resource_group.name
  api_management_name = azurerm_api_management.my_api_management.name
  revision            = "1"
  display_name        = "My API"
  path                = "myapi"
  import {
    content_format = "swagger-link-json"
    content_value  = "URL_TO_YOUR_SWAGGER_DEFINITION"  # Cambia esto a la URL de tu definición Swagger
  }
}

resource "azurerm_api_management_api_operation" "my_operation" {
  operation_id        = "myoperation"  # Cambia esto a un nombre único
  api_name            = azurerm_api_management_api.my_api.name
  api_management_name = azurerm_api_management.my_api_management.name
  display_name        = "My Operation"
  method              = "GET"
  response {
    status = 200
    description = "Success"
  }
}

# Exporta la URL de la API Gateway
output "api_gateway_url" {
  value = azurerm_api_management.my_api_management.portal_url
}

# Exporta la URL de la CDN de Azure
output "cdn_url" {
  value = azurerm_cdn_endpoint.my_cdn_endpoint.host_name
}
