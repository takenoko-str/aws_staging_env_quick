```
# init plugins
terraform init

# Show plan
terraform plan

# Show plan by overriding a variable
terraform plan -var region=eu-west-1

# Show plan with variables file
terraform plan -var-file=variables.tfvars

# Apply
terraform apply

# Apply single instance
terraform destroy -target <resource type>.<resource name>
# with module
terraform destroy -target module.<module name>.<resource type>.<resource name>

# Destroy
terraform destroy

# Destroy single instance
# without module
terraform destroy -target <resource type>.<resource name>
# with module
terraform destroy -target module.<module name>.<resource type>.<resource name>

# Mark a resource for recreation
# with module
terraform taint -module=<module name> <resource type>.<resource name>
# without module
terraform taint <resource type>.<resource name>

# List all resources
terraform state list

# Rename resource
terraform state mv module.<old_module_name>.<old_resource_type>.<old_resource_name> module.<new_module_name>.<new_resource_type>.<new_resource_name>

# Workspaces
terraform workspaces list
terraform workspaces new <workspace_name>
terraform workspaces select <workspace_name>
```