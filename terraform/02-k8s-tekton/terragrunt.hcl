include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Automatically wire the output of the infrastructure module as an input variable here
dependency "infrastructure" {
  config_path = "../01-infrastructure"

  # Mock outputs allow terragrunt plan/validate to pass before infrastructure is created
  mock_outputs = {
    cluster_ocid = "ocid1.cluster.oc1.aaaaaaaamockclusterid"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  cluster_id = dependency.infrastructure.outputs.cluster_ocid
}