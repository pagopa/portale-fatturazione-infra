#
# azuread groups
#
data "azuread_group" "adgroup_admins" {
  display_name = "${local.project}-adgroup-admin"
}

data "azuread_group" "adgroup_developers" {
  display_name = "${local.project}-adgroup-developers"
}

data "azuread_group" "adgroup_externals" {
  display_name = "${local.project}-adgroup-externals"
}

data "azuread_group" "adgroup_security" {
  display_name = "${local.project}-adgroup-security"
}

#
# azuread apps
#
data "azuread_application" "vpn" {
  count = var.vpn_enabled ? 1 : 0

  # hardcoded, created in eng-azure-authorization
  display_name = "${local.project}-app-vpn"
}

