@description('initial')
param initial string

@description('env')
param env string

@description('short-location')
param short_location string

@description('Network range 10.xx.0.0/16')
param networkRange int

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of resource.')
param vnetName string = '${initial}-${env}-vn-${short_location}'

@description('subnet-Name')
param subnetAPIM string
param subnetCosmosDB string
param subnetDBSQL string
param subnetSAP string
param subnetStub string
param subnetqavm string
param subnetdevelopment string
param subnetdatalake string
param subnetAzureBastion string

var vnetAddressPrefix = '10.${networkRange}.0.0/16'

var subnetApimPrefix  = '10.${networkRange}.0.0/24'
var subnetApimName = subnetAPIM

var subnetCosmosDBPrefix  = '10.${networkRange}.1.0/24'
var subnetCosmosDBName = subnetCosmosDB

var subnetDBSQLPrefix  = '10.${networkRange}.2.0/24'
var subnetDBSQLName = subnetDBSQL

var subnetSAPPrefix  = '10.${networkRange}.3.0/24'
var subnetSAPName = subnetSAP

var subnetStubPrefix  = '10.${networkRange}.4.0/24'
var subnetStubName = subnetStub

var subnetqavmPrefix  = '10.${networkRange}.5.0/24'
var subnetqavmName = subnetqavm

var subnetdevlopmentPrefix  = '10.${networkRange}.6.0/24'
var subnetdevelopmentName = subnetdevelopment

var subnetAzureBastionPrefix  = '10.${networkRange}.7.0/24'
var subnetAzureBastionName = subnetAzureBastion

var subnetdatalakePrefix  = '10.${networkRange}.8.0/24'
var subnetdatalakeName = subnetdatalake

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

output subnetDB string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetCosmosDBName)

output vnet string = vnet.id
output vnetname string = vnetName
