param privateDNSZoneName string = 'privatelink.azure-api.net'

param virtualNetworkName string

param privateEndpointName string

param apimIP string

//param domainName string

param apimEndpoints array = [
  'portal'
  'api'
  'management'
]

var privateEndpointId = resourceId('Microsoft.Network/privateEndpoints', privateEndpointName)


resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDNSZoneName
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZones
  name: '${privateDnsZones.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/VirtualNetworks', virtualNetworkName)
    }
  }
}
// resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' existing = {
//   name: privateEndpointName
// }
// resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-08-01' = {
//   parent: privateEndpoint
//   name: 'dnsgroupname'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config1'
//         properties: {
//           privateDnsZoneId: privateDnsZones.id
//         }
//       }
//     ]
//   }
// }

resource privateDnsRecordset 'Microsoft.Network/privateDnsZones/A@2020-06-01' = [ for name in apimEndpoints: {
  parent: privateDnsZones
  name: '${name}'
  properties: {
    ttl: 7200
    aRecords: [
      {
        ipv4Address: apimIP
      }
    ]
  }
}]
