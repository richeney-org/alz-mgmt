removed {
  from = module.management_groups[0].azapi_resource_action.subscription_placement_delete["security"]

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.management_groups[0].azapi_resource_action.subscription_placement_delete["identity"]

  lifecycle {
    destroy = false
  }
}
