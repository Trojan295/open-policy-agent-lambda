package policies.terraform

test_deny_if_without_project_tag {
  deny with input as {
    "planned_values": {
      "root_module": {
        "resources": [
          {
            "address": "dsda",
            "values": {
              "tags": {
                "Environment": "dev",
              }
            }
          }
        ]
      }
    }
  }
}

test_deny_if_without_environment_tag {
  deny with input as {
    "planned_values": {
      "root_module": {
        "resources": [
          {
            "address": "dsda",
            "values": {
              "tags": {
                "Project": "Cloud",
              }
            }
          }
        ]
      }
    }
  }
}
