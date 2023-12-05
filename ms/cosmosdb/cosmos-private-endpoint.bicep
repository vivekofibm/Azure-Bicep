@description('Location for all resources.')
param location string = resourceGroup().location

@description('Virtual network name')
param virtualNetworkName string

@description('Subnet Name')
param subnetName string

@description('Cosmos DB account name (must contain only lowercase letters, digits, and hyphens)')
@maxLength(44)
@minLength(3)
param accountName string

@description('Enable public network traffic to access the account; if set to Disabled, public network traffic will be blocked even before the private endpoint is created')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string 

@description('Private endpoint name')
param privateEndpointName string

@description('Capacity Total Throughput Limit')
param capacityThroughputLimit int = 400

var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

// resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2021-08-01' = {
//   name: virtualNetworkName
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         '172.20.0.0/16'
//       ]
//     }
//     subnets: [
//       {
//         name: subnetName
//         properties: {
//           addressPrefix: '172.20.0.0/24'
//           privateEndpointNetworkPolicies: 'Disabled'
//         }
//       }
//     ]
//   }
// }

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    capacity: {
      totalThroughputLimit: capacityThroughputLimit
    }
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: true
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkRules: [
      {
        id: resourceId('Microsoft.Network/VirtualNetworks/subnets', virtualNetworkName, subnetName)
        ignoreMissingVNetServiceEndpoint: false
      }
    ]
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/VirtualNetworks/subnets', virtualNetworkName, subnetName)
    }
    privateLinkServiceConnections: [
      {
        name: 'MyConnection'
        properties: {
          privateLinkServiceId: databaseAccount.id
          groupIds: [
            'Sql'
          ]
        }
      }
    ]
  }
}
