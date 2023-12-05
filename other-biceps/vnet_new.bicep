@description('Network range 10.xx.0.0/16')
param networkRange int = 110

@description('Location for all resources.')
param location string = resourceGroup().location

param vnetName string = 'ou-dih-test-vn-we-V2'

var vnetAddressPrefix = '10.${networkRange}.0.0/16'

var subnetApimPrefix  = '10.${networkRange}.0.0/24'
var subnetApimName = 'API'

var subnetCosmosDBPrefix  = '10.${networkRange}.1.0/24'
var subnetCosmosDBName = 'DB'

var subnetDBSQLPrefix  = '10.${networkRange}.2.0/24'
var subnetDBSQLName = 'DBSQL'

var subnetSAPPrefix  = '10.${networkRange}.3.0/24'
var subnetSAPName = 'SAPCC'

var subnetStubPrefix  = '10.${networkRange}.4.0/24'
var subnetStubName = 'STUB'

var subnetqavmPrefix  = '10.${networkRange}.5.0/24'
var subnetqavmName = 'QAVM'

var subnetdevlopmentPrefix  = '10.${networkRange}.6.0/24'
var subnetdevelopmentName = 'development'

var subnetAzureBastionPrefix  = '10.${networkRange}.7.0/24'
var subnetAzureBastionName = 'AzureBastionSubnet'

var subnetdatalakePrefix  = '10.${networkRange}.8.0/24'
var subnetdatalakeName = 'DataLake'

var ServiceEndpointsCosmosDB = [
  {
    service: 'Microsoft.AzureCosmosDB'
  }
]

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
        name:  subnetApimName 
        properties: {
          addressPrefix: subnetApimPrefix
                    
        }
      }
      {
        name: subnetCosmosDBName
        properties: {
          addressPrefix: subnetCosmosDBPrefix
          serviceEndpoints: ServiceEndpointsCosmosDB
          delegations: [
            {
              name: 'Microsoft.Web.serverFarms'
              properties:{
                serviceName: 'Microsoft.Web/serverFarms'
              }
              type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
            }
          ]
        }
      }
      {
        name: subnetDBSQLName
        properties: {
          addressPrefix: subnetDBSQLPrefix
        }
      }
      {
        name: subnetStubName
        properties: {
          addressPrefix: subnetStubPrefix
        }
      }
      {
        name: subnetSAPName
        properties: {
          addressPrefix: subnetSAPPrefix
        }
      }
      {
        name: subnetqavmName
        properties: {
          addressPrefix: subnetqavmPrefix
        }
      }
      {
        name: subnetdevelopmentName
        properties: {
          addressPrefix: subnetdevlopmentPrefix
        }
      }
      {
        name: subnetAzureBastionName
        properties: {
          addressPrefix: subnetAzureBastionPrefix
        }
      }
      {
        name: subnetdatalakeName
        properties: {
          addressPrefix: subnetdatalakePrefix
        }
      }
    ]
  }
}
output cosmosdbsubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetCosmosDBName)
output subnetDB string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetCosmosDBName)

output vnet string = vnet.id
output vnetname string = vnetName
