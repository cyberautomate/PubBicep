// Virtual Network Gateway Requirements
Subscription - Configured via azCLI before executing the template
Name - VPN name
Region - Azure region where the gateway lives 'usgovvirginia'
Gateway Type - 'Vpn' or 'ExpressRoute'
SKU - Options:
'Basic'
'ErGw1AZ'
'ErGw2AZ'
'ErGw3AZ'
'ErGwScale'
'HighPerformance'
'Standard'
'UltraPerformance'
'VpnGw1'
'VpnGw1AZ'
'VpnGw2'
'VpnGw2AZ'
'VpnGw3'
'VpnGw3AZ'
'VpnGw4'
'VpnGw4AZ'
'VpnGw5'
'VpnGw5AZ'
Tier - 'Same as above'
Virtual Network - Create a new Vnet named 'HubVnet'
Public IPaddress - Create New
Public IP address name - VPNPublicIP1
Public IP address SKU - 'Standard'
Public IP address allocation method - 'static'
Availability Zone - '1'
Enable active-active mode - 'enabled'

Secondary Public IPaddress - Create New
Secondary Public IP address name - VPNPublicIP2
Secondary Public IP address SKU - 'Standard'
Secondary Public IP address allocation method - 'static'
Availability Zone - '1'
Configure BGP - 'Disabled'
