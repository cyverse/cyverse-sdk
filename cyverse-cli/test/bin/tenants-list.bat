#!/usr/bin/env bats

@test "tenants-list by id returns tenant id" {
  result="$(tenants-list agave.prod)"
  [ "$result" = "agave.prod" ]
}

@test "tenants-list returns multiple tenants" {
  result="$(tenants-list | wc -l)"
  [ "$result" -ge 1 ]
}