vars=$(gh variable list --json name,value | jq 'map({(.name): .value}) | add')
sub="$(jq -r .AZURE_SUBSCRIPTION_ID <<< $vars)"
rg="$(jq -r .BACKEND_AZURE_RESOURCE_GROUP_NAME <<< $vars)"
sa="$(jq -r .BACKEND_AZURE_STORAGE_ACCOUNT_NAME <<< $vars)"
container="$(jq -r .BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME <<< $vars)"

cat > terraform_override.tf << EOF
# Overrides to enable local terraform plan

terraform {
  backend "azurerm" {
    use_azuread_auth     = true
    subscription_id      = "$sub"
    resource_group_name  = "$rg"
    storage_account_name = "$sa"
    container_name       = "$container"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "$(jq -r .AZURE_SUBSCRIPTION_ID <<< $vars)"
}
EOF
echo "Created terraform_override.tf using the GitHub Actions variables"

# Add Blob Reader role
id="/subscriptions/$sub/resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/$sa"
scope="$id/blobServices/default/containers/$container"
az role assignment create --role "Storage Blob Data Reader" --scope $scope --assignee $(az ad signed-in-user show --query id -otsv)

# Allow my public IP
public_ip=$(curl -s ipinfo.io/ip)
az storage account update --ids "$id" --public-network-access Enabled --default-action Deny
az storage account network-rule add --subscription "$sub" --resource-group "$rg" --account-name  "$id" --ip-address "$public_ip"

address_space=$(curl -s ipinfo.io/ip | cut -d. -f1-2).0.0/16
az storage account update --ids "$id" --public-network-access Enabled --default-action Deny
az storage account network-rule add --subscription "$sub" --resource-group "$rg" --account-name "$sa" --ip-address "$address_space"

# terraform init -reconfigure
# terraform plan -lock=false
# Update terraform.tf

# provider "alz" {
  # library_overwrite_enabled = true
  # library_references = [
    # {
      # path = "platform/alz"
      # ref  = "2025.09.3"
    # },
    # {
      # custom_url = "${path.root}/lib"
    # }
  # ]
# }

# ~/git/alz-mgmt (main) $ ll -d ./.alzlib/*/*
# drwxr-xr-x 9 richeney richeney 4096 Dec 10 15:50 ./.alzlib/769917479/886ca76d4870965724e41c9252e7a75fb9eca3fb344838088f95f084
# lrwxrwxrwx 1 richeney richeney   31 Dec 10 15:50 ./.alzlib/769917479/97a0913ff236482dbc5bfba9a9e8c81f1f2c883ef66f22fa680d019d -> /home/richeney/git/alz-mgmt/lib
# first level is generated, second is possibly a hash - predictable value regardless

# Update management_groups module with   architecture_name  = "alz_custom"
# Plan and undo

# <https://azure.github.io/Azure-Landing-Zones/accelerator/startermodules/terraform-platform-landing-zone/options/slz>
# I have copied the original and manually renamed the new one created in as lib/architecture_definitions/slz_custom.alz_architecture_definition.yaml
