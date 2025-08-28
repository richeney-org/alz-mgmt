# Empty configuration

This configuration includes a (relatively) minimal set of files to get you started, including a custom library.

The config will install the providers and includes the GitHub Actions workflow, and also included a customer library for the main avm-ptn-alz module.

You may then reference the [Azure Landing Zone AVM modules](https://registry.terraform.io/search/modules?q=Azure%2Favm-ptn-alz) to create your own configuration. Each module has a drop down of examples to use as a starting point. For example, the [management example](https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest/examples/management) for the core Azure Landing Zone pattern module. This page includes an example config based on this.

Below are the setup steps for Terraform and GitHub using the recommended details. Reference the [ALZ Accelerator documentation](https://aka.ms/alz/accelerator/docs) for alternative approaches.

## Setup

### Prereqs

1. Binaries

    You will need at least the specified version of

    - [PowerShell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell) (7.4)
    - [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (2.55.0)
    - [Git](https://git-scm.com/downloads)

1. ALZ PowerShell modules

   ```powershell
   Install-Module -Name ALZ
   ```

   Use `Update-Module ALZ` to update.

1. Authorisation

    Elevate in Entra ID's tenant properties, then assign yourself as Owner at tenant root group.

    ```shell

    az role assignment create --assignee "$(az ad signed-in-user show --query id -otsv)" --role "Owner" --scope "/providers/Microsoft.Management/managementGroups/$(az account show --query tenantId -otsv)"
    ```

    You may remove the RBAC role assignment once the accelerator has run.

1. Create personal access tokens for the accelerator and private runners

    Create the two [personal access tokens](https://github.com/settings/tokens). Save the generated token for each.

    ### Azure Landing Zone Terraform Accelerator

    - repo
    - workflow
    - admin:org
    - user : read:user
    - user : read:email
    - delete_repo

    Short expiry, e.g. tomorrow.

    ### Azure Landing Zone Private Runners

    - repo
    - admin:org (for Enterprise organization only)

    Permanent.

### Bootstrap

```powershell
New-Item -ItemType "file" "~/accelerator/config/inputs.yaml" -Force
New-Item -ItemType "directory" "~/accelerator/output"
New-Item -ItemType "file" "~/accelerator/config/platform-landing-zone.tfvars" -Force
$tempFolderName = "~/accelerator/temp"
New-Item -ItemType "directory" $tempFolderName
$tempFolder = Resolve-Path -Path $tempFolderName
git clone -n --depth=1 --filter=tree:0 "https://github.com/Azure/alz-terraform-accelerator" "$tempFolder"
cd $tempFolder

$libFolderPath = "templates/platform_landing_zone/lib"
git sparse-checkout set --no-cone $libFolderPath
git checkout

cd ~
Copy-Item -Path "$tempFolder/$libFolderPath" -Destination "~/accelerator/config" -Recurse -Force
Remove-Item -Path $tempFolder -Recurse -Force

```



## Links

- <https://aka.ms/alz/accelerator/docs>