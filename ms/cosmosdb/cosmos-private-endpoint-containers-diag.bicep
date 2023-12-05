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
param capacityThroughputLimit int = 1300

@description('The name for the database')
param databaseName string = 'database1'

@description('The name for the container')
param containerName string = 'container1'

@description('The throughput for the container')
@minValue(400)
@maxValue(1000000)
param throughput int = 400

@description('eventHubAuthorizationRuleId')
param eventHubAuthorizationRuleId string

@description('eventHubName')
param eventHubName string

@description('Log Analytics WorkspaceId')
param workspaceId string

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

resource databaseAccountDiagsettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'cosmosdb-databaseaccounts-diagsettings'
  scope: databaseAccount
  properties: {
    eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
    eventHubName: eventHubName
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
      {
        category: 'QueryRuntimeStatistics'
        enabled: true
      }
      {
        category: 'PartitionKeyStatistics'
        enabled: true
      }
      {
        category: 'PartitionKeyRUConsumption'
        enabled: true
      }
      {
        category: 'ControlPlaneRequests'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Requests'
        enabled: true
      }
    ]
    workspaceId: workspaceId
  }
}
