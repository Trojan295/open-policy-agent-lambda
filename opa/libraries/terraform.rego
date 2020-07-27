package libraries.terraform

get_resources_by_types(resource_types) = { res | 
  res := get_resources_by_type(resource_types[_], resources)[_]
}

get_resources_by_type(resource_type, resources) = { res |
  res := resources[_]
  res.type == resource_type
}

taggable_resources := { r | 
  r := resources[_]
  r.values["tags"]
}

resources := { r |
  some path, value

  walk(input.planned_values, [path, value])

  rs := module_resources(path, value)

  r := rs[_]
}

created := [res | res := resource_changes[_]; res.change.actions[_] == "create"]

updated := [res | res := resource_changes[_]; res.change.actions[_] == "update"]

deleted := [res | res := resource_changes[_]; res.change.actions[_] == "delete"]

resource_changes := input.resource_changes

module_resources(path, value) = rs {
  reverse_index(path, 1) == "resources"
  reverse_index(path, 2) == "root_module"
  rs := value
}

module_resources(path, value) = rs {
  reverse_index(path, 1) == "resources"
  reverse_index(path, 3) == "child_modules"
  rs := value
}

reverse_index(path, idx) = value {
	value := path[count(path) - idx]
}