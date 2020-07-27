package policies.terraform

import data.libraries.terraform
import data.libraries.common

required_tags = {
  "Project",
  "Environment",
}

errors[msg] {
  tags = terraform.taggable_resources[res].values.tags
  keys := { key | tags[key] }

  required_tag := required_tags[_]
  not common.contains(keys, required_tag)

  msg := sprintf("Error in resource %v. Missing required tag %v", [res.address, required_tag])
}

deny {
  count(errors) > 0
}

deleted_count := count(terraform.deleted)

created_count := count(terraform.created)

updated_count := count(terraform.updated)

weights := {
  "delete": 20, "create": 5, "update": 1
}

score := num {
  num := deleted_count * weights["delete"] +
    created_count * weights["create"] +
    updated_count * weights["update"]
}

approve := score < 50
