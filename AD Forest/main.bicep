@description('Username for the Virtual Machine.')
param adminUsername string = 'chief'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('The Windows version for the VM. This will pick a fully patched Gen2 image of this given Windows version.')
@allowed([
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-smalldisk-g2'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_B2s'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine.')
param vmName string = 'onPremDC'

//@description('FQDN of domain being built inside the DC VM')
//param domainFQDN string = 'chiefslab.local'

//@description('Virtual Network address space of the exiting vNET')
//param virtualNetworkAddressSpace string = '10.0.121.0/26'

//@description('Subnet range where the DC VM will live')
//param subnetAddressRange string = '10.0.121.0/27'

var logAnalyticsRG = 'mymlz-rg-operations-mlz'
var logAnalyticsWorkspaceName = 'mymlz-log-operations-mlz'
var storageAccountName = 'mymlzstonpremebxxtcvdy6'
var subnetName = 'mymlz-snet-onPrem-mlz'
var virtualNetworkName = 'mymlz-vnet-onPrem-mlz'
var networkSecurityGroupName = 'mymlz-nsg-onPrem-mlz'
//var url = 'https://github.com/joshua-a-lucas/BlueTeamLab/raw/main/scripts/Deploy-DomainServices.zip'

resource stg 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' existing =  {
  name: networkSecurityGroupName
}

resource vn 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: virtualNetworkName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsRG)
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${vmName}-NIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${vmName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vn.name, subnetName)
          }
        }
      }
    ]
  }
}

resource svrVM 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption:'Delete'
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
          deleteOption:'Delete'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption:'Delete'
          }

        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: stg.properties.primaryEndpoints.blob
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource dependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: '${svrVM.name}/DependencyAgentWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

resource policyExtension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: '${svrVM.name}/AzurePolicyforWindows'
  location: location
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

resource mmaExtension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: '${svrVM.name}/MMAExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    settings: {
      workspaceId: reference(logAnalyticsWorkspace.id , '2015-11-01-preview').customerId
      stopOnMultipleConnections: true
    }
    protectedSettings: {
      workspaceKey: listKeys(logAnalyticsWorkspace.id , '2015-11-01-preview').primarySharedKey
    }
  }
}

resource networkWatcher 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: '${svrVM.name}/Microsoft.Azure.NetworkWatcher'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentWindows'
    typeHandlerVersion: '1.4'
  }
}

// Use PowerShell DSC to deploy Active Directory Domain Services on the domain controller
/*
resource domainControllerConfiguration 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${svrVM.name}/Microsoft.Powershell.DSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: url
      ConfigurationFunction: 'Deploy-DomainServices.ps1\\Deploy-DomainServices'
      Properties: {
        domainFQDN: domainFQDN
        adminCredential: {
          UserName: adminUsername
          Password: 'PrivateSettingsRef:adminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
          adminPassword: adminPassword
      }
    }
  }
}

// Update the virtual network with the domain controller as the primary DNS server
module virtualNetworkDNS 'modules/updateVNET.bicep' = {
  name: '${svrVM}.virtualNetworkDNS'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressSpace: virtualNetworkAddressSpace
    subnetName: subnetName
    subnetAddressRange: subnetAddressRange
    dnsServerIPAddress: nic.properties.ipConfigurations[0].properties.privateIPAddress
    nsg: nsg.id
  }
}
*/
