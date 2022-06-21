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
$deployDefender = $true
$deploySentinel = $true
$deployRemoteAccess = $true

New-AzSubscriptionDeployment -Name $name `
-Location $location `
-TemplateFile $templateFile `
-resourcePrefix $resourcePrefix `
-deployDefender $deployDefender `
-deploySentinel $deploySentinel `
-deployRemoteAccess $deployRemoteAccess `
-Verbose

# Get all Resource Groups after MLZ deployment
Get-AzResourceGroup | Select-Object -Property ResourceGroupName

# Deploy VM to MLZ
$vmTemplateFile = 'main.bicep'
$adDeploymentName = 'Deploy-Domain-Controller'
$resourceGroupName = 'mymlz-rg-onPrem-mlz'

New-AzResourceGroupDeployment -TemplateFile $vmTemplateFile -Name $adDeploymentName -ResourceGroupName $resourceGroupName -Verbose








# Cleanup after deployment
$filter = 'mymlz-rg'

Get-AzResourceGroup | Where-Object ResourceGroupName -match $filter | Remove-AzResourceGroup -AsJob -Force