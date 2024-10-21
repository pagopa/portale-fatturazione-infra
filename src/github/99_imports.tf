import {
  to = github_repository.this["portale-fatturazione-infra"]
  id = "portale-fatturazione-infra"
}

import {
  to = github_repository.this["portale-fatturazione-be"]
  id = "portale-fatturazione-be"
}

import {
  to = github_repository.this["portale-fatturazione-fe"]
  id = "portale-fatturazione-fe"
}

import {
  to = github_repository_environment.this["portale-fatturazione-be##prod"]
  id = "portale-fatturazione-be:prod"
}

import {
  to = github_branch_protection.this["portale-fatturazione-infra"]
  id = "portale-fatturazione-infra:main"
}

import {
  to = github_branch_protection.this["portale-fatturazione-be"]
  id = "portale-fatturazione-be:main"
}

import {
  to = github_branch_protection.this["portale-fatturazione-fe"]
  id = "portale-fatturazione-fe:main"
}
