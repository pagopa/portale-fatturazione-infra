#
# azuread groups
#
data "azuread_group" "adgroup_admins" {
  display_name = format("%s-%s", local.project, "adgroup-admin")
}

data "azuread_group" "adgroup_developers" {
  display_name = format("%s-adgroup-developers", local.project)
}

data "azuread_group" "adgroup_externals" {
  display_name = format("%s-adgroup-externals", local.project)
}

data "azuread_group" "adgroup_security" {
  display_name = format("%s-adgroup-security", local.project)
}
