@description('The name of the function app that you wish to create.')
param appName string = 'ou-dih-acct-fn-we'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'dotnet'

@description('Subnet Name')
param subnetCosmosDBName string = 'DB'

var functionAppName = appName
var hostingPlanName = 'ou-dih-acct-asp-we'
//var vnetName = 'ou-dih-acct-we-test'
var vnetName = 'ou-dih-test-vn-we-V2'
//var subnetName = 'DB'
var storageAccountName = 'oudihsawe'
var functionWorkerRuntime = runtime

// resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
//   name: vnetName
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         '10.101.0.0/16'
//       ]
//     }
//     subnets: [
//       {
//         name: subnetName
//         properties: {
//           addressPrefix: '10.101.1.0/24'
//           delegations: [
//             {
//               name: 'Microsoft.Web/serverFarms'
//               properties: {
//                 serviceName: 'Microsoft.Web/serverFarms'
//               }
//             }
//           ]

//         }
//       }
//     ]
//   }
//   dependsOn: [
    
//   ]
  
// }


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // virtualNetworkRules: [
    //   {
    //     id: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetCosmosDBName)
    //     ignoreMissingVNetServiceEndpoint: true
    //   }
    // ]
   virtualNetworkSubnetId: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetCosmosDBName)
   //virtualNetworkSubnetId: subnetCosmosDBName
   //virtualNetworkSubnetId: 'subscriptions/94ef17bd-8a0a-4325-89bb-329147622f1a/resourceGroups/rg-ou/providers/Microsoft.Network/VirtualNetworks/ou-dih-test-vn-we-V2/subnets/DB'
    serverFarmId: hostingPlan.id
    siteConfig: {
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~10'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}


