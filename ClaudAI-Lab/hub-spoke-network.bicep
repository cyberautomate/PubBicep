param hubVnetName string = 'hubVnet'
param hubSubnetName string = 'hubSubnet'
param spoke1VnetName string = 'spoke1Vnet'
param spoke1SubnetName string = 'spoke1Subnet'
param spoke2VnetName string = 'spoke2Vnet'
param spoke2SubnetName string = 'spoke2Subnet'

resource hubVnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: hubVnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource hubSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  parent: hubVnet
  name: hubSubnetName
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource spoke1Vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: spoke1VnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
  }
}

resource spoke1Subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  parent: spoke1Vnet
  name: spoke1SubnetName
  properties: {
    addressPrefix: '10.1.0.0/24'
  }
}

resource spoke2Vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: spoke2VnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
  }
}

resource spoke2Subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  parent: spoke2Vnet
  name: spoke2SubnetName
  properties: {
    addressPrefix: '10.2.0.0/24'
  }
}

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: 'vpnGateway'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'VPNPubIP'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: 'subnet.id'
          }
          publicIPAddress: {
            id: 'publicIPAdresses.id'
          }
        }
      }
    ]
    sku: {
      name: 'Basic'
      tier: 'Basic'
    }
    gatewayType: 'Vpn'
    vpnType: 'PolicyBased'
    enableBgp: false
  }
}
