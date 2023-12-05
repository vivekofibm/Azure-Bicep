@description('Location for all resources.')
param location string = resourceGroup().location

@description('Virtual network name')
param virtualNetworkName string = 'ou-dih-acct-we-test'

@description('Subnet Name')
param subnetName string = 'DB'

@description('Cosmos DB account name (must contain only lowercase letters, digits, and hyphens)')
@maxLength(44)
@minLength(3)
param accountName string = 'ou-dih-acct-cd-we-test'

@description('Enable public network traffic to access the account; if set to Disabled, public network traffic will be blocked even before the private endpoint is created')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Private endpoint name')
param privateEndpointName string = 'ou-dih-acct-cd-pe-we-test'

@description('Capacity Total Throughput Limit')
param capacityThroughputLimit int = 1300

@description('The name for the database')
param databaseName string = 'database1'

@description('The name for the container')
param containerName string = 'container1'

@description('The throughput for the container')
@minValue(400)
@maxValue(1000000)
param throughput int = 400


var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]


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
    ipRules: [
      {
        ipAddressOrRange: '104.42.195.92'
      }
      {
        ipAddressOrRange: '40.76.54.131'
      }
      {
        ipAddressOrRange: '52.176.6.30'
      }
      {
        ipAddressOrRange: '52.169.50.45'
      }
      {
        ipAddressOrRange: '52.187.184.26'
      }
    ]
    isVirtualNetworkFilterEnabled: true
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkRules: [
      {
        id: resourceId('Microsoft.Network/VirtualNetworks/subnets', virtualNetworkName, subnetName)
        ignoreMissingVNetServiceEndpoint: true
      }
    ]
  }
}

// resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
//   name: privateEndpointName
//   location: location
//   properties: {
//     subnet: {
//       id: resourceId('Microsoft.Network/VirtualNetworks/subnets', virtualNetworkName, subnetName)
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'MyConnection'
//         properties: {
//           privateLinkServiceId: databaseAccount.id
//           groupIds: [
//             'Sql'
//           ]
//         }
//       }
//     ]
//   }
// }

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  parent: databaseAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  parent: database
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
      }
    }
    options: {
      throughput: throughput
    }
  }
}

