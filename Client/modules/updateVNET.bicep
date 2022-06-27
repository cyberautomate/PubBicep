param location string
param virtualNetworkName string
param virtualNetworkAddressSpace string
param subnetName string
param subnetAddressRange string
param dnsServerIPAddress string = ''
param nsg string

// Deploy the virtual network and a default subnet associated with the network security group
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressSpace
      ]
    }
    dhcpOptions: {
      dnsServers: ((!empty(dnsServerIPAddress)) ? array(dnsServerIPAddress) : json('null'))
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressRange
          networkSecurityGroup: {
            id: nsg
          }
        }
      }
    ]
  }
}
