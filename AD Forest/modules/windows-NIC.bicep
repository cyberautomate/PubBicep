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

resource onPremVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: onPremVirtualNetworkName
}


module windowsNetworkInterface 'network-interface.bicep' = {
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

// OUTPUTS

