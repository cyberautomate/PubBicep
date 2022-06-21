/*
Copyright (c) Microsoft Corporation.
Licensed under the MIT License.
*/

param location string
param tags object = {}

param onPremVirtualNetworkName string
param onPremSubnetResourceId string
param onPremNetworkSecurityGroupResourceId string

param windowsSVRNetworkInterfaceName string
param windowsSVRNetworkInterfaceIpConfigurationName string
param windowsSVRNetworkInterfacePrivateIPAddressAllocationMethod string

param windowsSVRVmName string
param windowsSVRVmSize string
param windowsSVRVmAdminUsername string
@secure()
@minLength(12)
param windowsSVRVmAdminPassword string
param windowsSVRVmPublisher string
param windowsSVRVmOffer string
param windowsSVRVmSku string
param windowsSVRVmVersion string
param windowsSVRVmCreateOption string
param windowsSVRVmStorageAccountType string

param logAnalyticsWorkspaceId string

resource onPremVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: onPremVirtualNetworkName
}


module windowsNetworkInterface '../modules/network-interface.bicep' = {
  name: 'remoteAccess-windowsNetworkInterface'
  params: {
    name: windowsSVRNetworkInterfaceName
    location: location
    tags: tags
    
    ipConfigurationName: windowsSVRNetworkInterfaceIpConfigurationName
    networkSecurityGroupId: onPremNetworkSecurityGroupResourceId
    privateIPAddressAllocationMethod: windowsSVRNetworkInterfacePrivateIPAddressAllocationMethod
    subnetId: onPremSubnetResourceId
  }
}

module windowsSVRVirtualMachine '../modules/windowsSVR-virtual-machine.bicep' = {
  name: 'windowsSVRVirtualMachine'
  params: {
    name: windowsSVRVmName
    location: location
    tags: tags

    size: windowsSVRVmSize
    adminUsername: windowsSVRVmAdminUsername
    adminPassword: windowsSVRVmAdminPassword
    publisher: windowsSVRVmPublisher
    offer: windowsSVRVmOffer
    sku: windowsSVRVmSku
    version: windowsSVRVmVersion
    createOption: windowsSVRVmCreateOption
    storageAccountType: windowsSVRVmStorageAccountType
    networkInterfaceName: windowsSVRNetworkInterfaceName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// OUTPUTS

