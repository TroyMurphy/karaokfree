resource "azurerm_service_plan" "sp" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_application_insights" "ai" {
  name                = var.web_application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_web_pubsub" "wps" {
  name                = var.web_pubsub_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku      = "Standard_S1"
  capacity = 1

  public_network_access_enabled = false

  live_trace {
    enabled                   = true
    messaging_logs_enabled    = true
    connectivity_logs_enabled = false
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7

  access_policy {
    tenant_id = var.tenant_id
    object_id = azurerm_linux_web_app.web.identity[0].principal_id

    key_permissions = [
      "Get",
      "List"
    ]
    secret_permissions = [
      "Get",
      "List"
    ]
  }
}

resource "azurerm_key_vault_secret" "wps_connection_string" {
  name         = "WebPubSubConnectionString"
  value        = azurerm_web_pubsub.wps.primary_connection_string
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_linux_web_app" "web" {
  name                          = var.web_app_name
  location                      = var.location
  public_network_access_enabled = true
  resource_group_name           = var.resource_group_name
  service_plan_id               = azurerm_service_plan.sp.id
  https_only                    = true
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    vnet_route_all_enabled = true
    ftps_state             = "Disabled"
    http2_enabled          = true
    always_on              = false
    use_32_bit_worker      = false
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY          = azurerm_application_insights.ai.instrumentation_key
    ApplicationInsights__InstrumentationKey = azurerm_application_insights.ai.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING   = azurerm_application_insights.ai.connection_string
    TZ                                      = "America/Edmonton"
    Websockets__ConnectionString            = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.wps_connection_string.id})"
  }
}
