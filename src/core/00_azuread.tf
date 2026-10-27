#
# azuread groups
#
data "azuread_group" "adgroup_admins" {
  display_name = "${local.project}-adgroup-admin"
}

data "azuread_group" "adgroup_developers" {
  display_name = "${local.project}-adgroup-developers"
}

data "azuread_group" "adgroup_ext_data_developers" {
  count = var.env_short == "p" ? 1 : 0

  display_name = "${local.project}-adgroup-ext-data-developers"
}

#
# azuread apps
#
data "azuread_application" "portalefatturazione" {
  # hardcoded, created in eng-azure-authorization
  display_name = format("%s-%s", local.project, "portalefatturazione")
}


