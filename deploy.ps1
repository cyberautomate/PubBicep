break

# Login to whatever cloud you want to deploy to.
Connect-AzAccount

# If you have more than one subscription make sure you deploy to the correct one
Get-AzSubscription

Set-AzContext -Subscription '0dc9caa0-28f1-48cb-a7b6-e390f6212b39'


# Deploy Basic MLS located here: aka.ms/missionlz
$name = "Basic-MLZ"
$location = 'eastus'
$templateFile = 'mlz.bicep'
$resourcePrefix = "MyMLZ"

New-AzSubscriptionDeployment -Name $name -Location $location -TemplateFile $templateFile -resourcePrefix $resourcePrefix -Verbose

# Deploy above with Defedner and Sentinel 
# - Azure Firewall standard SKU
# - Sentinel deployed to the Log Analytics Workspace
# - Defender for Cloud Enabled

$name = "Sentinel-MLZ"
$location = 'eastus'
$templateFile = 'mlz.bicep'
$resourcePrefix = "MyMLZ"
$firewallSkuTier = 'Standard'
$deployDefender = $true
$deploySentinel = $true
$deployRemoteAccess = $true

New-AzSubscriptionDeployment -Name $name `
-Location $location `
-TemplateFile $templateFile `
-resourcePrefix $resourcePrefix `
-firewallSkuTier $firewallSkuTier `
-deployDefender $deployDefender `
-deploySentinel $deploySentinel `
-deployRemoteAccess $deployRemoteAccess `
-Verbose






# Cleanup after deployment
$filter = 'mymlz-rg'

Get-AzResourceGroup | Where-Object ResourceGroupName -match $filter | Remove-AzResourceGroup -AsJob -Force