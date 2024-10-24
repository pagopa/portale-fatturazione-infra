service_line = "fatturazione"

repositories = [
  {
    name                 = "portale-fatturazione-infra"
    description          = "Portale Fatturazione platform infrastructure"
    topics               = ["iac"]
    visibility           = "public"
    from_template        = "pagopa/terraform-infrastructure-template"
    rule_bypassing_teams = ["portalefatturazione-admin"]
  },
  {
    name                 = "portale-fatturazione-fe"
    description          = "Frontend of Portale Fatturazione"
    topics               = []
    visibility           = "public"
    rule_bypassing_teams = ["portalefatturazione-admin"]
  },
  {
    name                 = "portale-fatturazione-be"
    description          = "Backend of Portale Fatturazione"
    topics               = []
    visibility           = "public"
    rule_bypassing_teams = ["portalefatturazione-admin"]
    environments = [
      {
        name = "uat"
      },
      {
        name                    = "prod"
        require_review_by_teams = ["portalefatturazione-admin"]
      },
    ]
  },
]
