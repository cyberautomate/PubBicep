$ErrorActionPreference = "Stop"

$templateFile = 'main.bicep'
$location = 'eastus'
$resourceGroupName = 'ChiefsLab-Domain'
$today = Get-Date -Format 'MM-dd-yyyy'
$deploymentName = "singleVM-$today"
$myIP = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content

$array = @{
  myIP = $myIP
}

# Confirm the login information
$connected = Get-AzContext
if (!($connected)) {
	Microsoft.PowerShell.Utility\Write-Host "You must Login..."
	Login-AzAccount
	}

  $subs = Get-AzSubscription
    if ($subs.count -gt 1) {
      Write-Output "More than 1 Subscription. Select the subscription to use in the Out-Gridview window that has opened "
      $subtoUse = $subs | Out-GridView -Title 'Select the Subscription to use for this deployment' -PassThru
      $subscriptionId = $SubtoUse.$subscriptionId
    } else {
      $subscriptionId = $subs.Id
      Write-Host "Selecting Subscription '$subscriptionId'"
      Select-AzSubscription -Subscription $subscriptionId
    }

$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue

if (!($resourceGroup)) {
	Write-host "Resource Group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
	if (!($location)) {
	$location = Read-Host "location";
}

 Write-Host "Creating resource group '$resourceGroupName' in location '$location'"
 New-AzResourceGroup -Name $resourceGroupName -Location $location

} else {
	Write-Host "Using existing resource group '$resourceGroupName'"
}


New-AzResourceGroupDeployment -TemplateFile $templateFile -ResourceGroupName $resourceGroupName `
  -Name $deploymentName -TemplateParameterObject $array -Verbose