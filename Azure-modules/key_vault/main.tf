terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.50.0"
    }
  }
}

resource "azurerm_key_vault" "this" {
  name                        = coalesce(var.custom_name, "${var.prefix}-kv-${var.environment}-${var.location_short}")
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = var.sku_name

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  enable_rbac_authorization = var.use_access_policies ? false : var.enable_rbac_authorization
  purge_protection_enabled  = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [1] : []
    content {
      default_action             = var.private_endpoint_enabled ? "Deny" : var.network_acls.default_action
      bypass                     = var.network_acls.bypass
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }

  dynamic "access_policy" {
    for_each = var.use_access_policies ? var.access_policies : []
    content {
      tenant_id = access_policy.value.tenant_id
      object_id = access_policy.value.object_id

      secret_permissions      = access_policy.value.secret_permissions
      certificate_permissions = try(access_policy.value.certificate_permissions, [])
      key_permissions         = try(access_policy.value.key_permissions, [])
    }
  }

  tags = merge(
    var.tags,
    {
      environment = var.environment
      module      = "key-vault"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "keyvault_access" {
  for_each = var.use_access_policies ? toset([]) : toset(var.principal_ids)
  scope                = azurerm_key_vault.this.id
  role_definition_name = var.default_role
  principal_id         = each.key
}


resource "azurerm_private_endpoint" "this" {
  count               = var.private_endpoint_enabled ? 1 : 0
  name                = "${azurerm_key_vault.this.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_key_vault.this.name}-pe-conn"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.private_dns_zone_ids
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${azurerm_key_vault.this.name}-diag"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.diagnostics_storage_account_id

  enabled_log {
    category = "AuditEvent"

    retention_policy {
      enabled = var.diagnostic_retention_enabled
      days    = var.diagnostic_retention_days
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = var.diagnostic_retention_enabled
      days    = var.diagnostic_retention_days
    }
  }
}
