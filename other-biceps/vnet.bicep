@description('Network range 10.xx.0.0/16')
param networkRange int = 101

@description('Location for all resources.')
param location string = resourceGroup().location

var vnetName = 'ou-dih-acct-we-test'
var vnetAddressPrefix = '10.${networkRange}.0.0/16'

// Cosmosdb
var subnetCosmosDBPrefix = '10.${networkRange}.1.0/24'
var subnetCosmosDBName = 'DB'
//Service endpoints enabled on the CosmosDD subnet
var ServiceEndpointsCosmosDB = [
  {
    service: 'Microsoft.AzureCosmosDB'
  }
]

//Functions
var subnetFunctionsPrefix = '10.${networkRange}.5.0/24'
var subnetFunctionsName = 'DBSQL'

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [

      {
        name: subnetCosmosDBName
        properties: {
          addressPrefix: subnetCosmosDBPrefix
          serviceEndpoints: ServiceEndpointsCosmosDB
        }
      }
    ]
  }
}

output functionssubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetFunctionsName)
output functionssubnetname string = subnetFunctionsName

output cosmosdbsubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetCosmosDBName)
output cosmosdbsubnetname string = subnetCosmosDBName

output vnet string = vnet.id
output vnetname string = vnetName
