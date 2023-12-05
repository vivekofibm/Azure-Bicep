@description('location shoul be Global')
param locations string = 'global'

@description('Name you want to assign to DNS')
param privateDnsName string = 'privatelink.database.windows.net'

resource privatelink_database_windows_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDnsName
  location: locations
  tags: {}
  properties: {}
  }