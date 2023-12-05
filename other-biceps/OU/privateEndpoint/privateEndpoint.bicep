param location string = resourceGroup().location
param privateEndpointName string = 'ou-dih-test-pe-we'
param vnetName string = 'ou-dih-acct-vn-we'
param subnetName string =  'API'
param targetSubResource array =[
  'sqlServer'
]

resource sqlserver 'Microsoft.Sql/servers@2022-08-01-preview' existing = {
  name: 'ou-dih-test-we'
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: vnetName
  //scope: resourceGroup('ou-dih-test-rgshared-we')
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: subnetName
  parent: virtualNetwork
}


resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.database.windows.net'
}


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: location
  name: privateEndpointName
  properties: {
    subnet: {
      id: subnet.id
    }
    privateDnsZoneGroups: [
      {
        name: 'system'
        properties: {
          privateDnsZoneConfigs: [
            {
              name: 'zone1'
              properties: {
                privateDnsZoneId: dnsZone.id
              }
            }
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'qwerty-nic'
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: sqlserver.id
          groupIds: targetSubResource
        }
      }
    ]
    

  }
  tags: {}
  dependsOn: [
    dnsZone

  ]
}
