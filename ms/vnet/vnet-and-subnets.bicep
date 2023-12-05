@description('Project Name')
param projectName string

@description('env')
param env string = 'dev'

@description('Network range 10.xx.0.0/16')
param networkRange int = 101

@description('Location for all resources.')
param location string = resourceGroup().location

var vnetName = 'vnet-${projectName}-${env}'


var vnetAddressPrefix = '10.${networkRange}.0.0/16'

// ApiM
var subnetApimPrefix  = '10.${networkRange}.0.0/24'
var subnetApimName = 'subnet-${projectName}-apim-${env}'
// Cosmosdb
var subnetCosmosDBPrefix  = '10.${networkRange}.1.0/24'
var subnetCosmosDBName = 'subnet-${projectName}-cosmosdb-${env}'
//Service endpoints enabled on the CosmosDD subnet
var ServiceEndpointsCosmosDB = [
  {
    service: 'Microsoft.AzureCosmosDB'
  }
]

// adf
var subnetADFPrefix = '10.${networkRange}.2.0/24'
var subnetADFName = 'subnet-${projectName}-adf-${env}'

//keyvault
var subnetKeyVaultPrefix = '10.${networkRange}.3.0/24'
var subnetKeyVaultName = 'subnet-${projectName}-kv-${env}'

//Service endpoints enabled on the KeyVault subnet
var ServiceEndpointsKeyVault = [
  {
    service: 'Microsoft.KeyVault'
  }
]

//DataLake
var subnetDataLakePrefix = '10.${networkRange}.4.0/24'
var subnetDataLakeName  = 'subnet-${projectName}-datalake-${env}'

//Service endpoints enabled on the DataLake subnet
var ServiceEndpointsDataLake = [
  {
    service: 'Microsoft.Storage'
  }
]

//Functions
var subnetFunctionsPrefix = '10.${networkRange}.5.0/24'
var subnetFunctionsName = 'subnet-${projectName}-functions-${env}'

//Service endpoints enabled on the Functions subnet
var ServiceEndpointsFunctions = [
  {
    service: 'Microsoft.Web'
  }
]


// Application Gateway
var subnetAppGWPrefix = '10.${networkRange}.6.0/24'
var subnetAppGWName = 'subnet-${projectName}-appgw-${env}'

// SqlServer
var subnetSqlSrvPrefix = '10.${networkRange}.7.0/24'
var subnetSqlSrvName = 'subnet-${projectName}-sqlsrv-${env}'


resource apimnsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'apimsubnetnsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Management_endpoint_for_Azure_portal_and_Powershell'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_on_Redis_Cache'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6381-6383'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_to_sync_Rate_Limit_Inbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 135
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_on_Azure_SQL'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_for_Log_to_event_Hub_policy'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '5671'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 150
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Redis_Cache_outbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6381-6383'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 160
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_To_sync_RateLimit_Outbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 165
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Azure_File_Share_for_GIT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 170
          direction: 'Outbound'
        }
      }
      {
        name: 'Azure_Infrastructure_Load_Balancer'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6390'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 180
          direction: 'Inbound'
        }
      }
      {
        name: 'Publish_DiagnosticLogs_And_Metrics'
        properties: {
          description: 'API Management logs and metrics for consumption by admins and your IT team are all part of the management plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 185
          direction: 'Outbound'
          destinationPortRanges: [
            '443'
            '12000'
            '1886'
          ]
        }
      }
      {
        name: 'Connect_To_SMTP_Relay_For_SendingEmails'
        properties: {
          description: 'APIM features the ability to generate email traffic as part of the data plane and the management plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 190
          direction: 'Outbound'
          destinationPortRanges: [
            '25'
            '587'
            '25028'
          ]
        }
      }
      {
        name: 'Authenticate_To_Azure_Active_Directory'
        properties: {
          description: 'Connect to Azure Active Directory for developer portal authentication or for OAuth 2 flow during any proxy authentication'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureActiveDirectory'
          access: 'Allow'
          priority: 200
          direction: 'Outbound'
          destinationPortRanges: [
            '80'
            '443'
          ]
        }
      }
      {
        name: 'Dependency_on_Azure_Storage'
        properties: {
          description: 'APIM service dependency on Azure blob and Azure table storage'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Publish_Monitoring_Logs'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 300
          direction: 'Outbound'
        }
      }
      {
        name: 'Access_KeyVault'
        properties: {
          description: 'Allow API Management service control plane access to Azure Key Vault to refresh secrets'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureKeyVault'
          access: 'Allow'
          priority: 350
          direction: 'Outbound'
          destinationPortRanges: [
            '443'
          ]
        }
      }
      {
        name: 'Deny_All_Internet_Outbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 999
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource appgwnsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'appgwsubnetnsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AppGw_inbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AppGw_inbound_Internet'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

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
          networkSecurityGroup: {
            id: apimnsg.id
          }
          
        }
      }
      {
        name: subnetCosmosDBName
        properties: {
          addressPrefix: subnetCosmosDBPrefix
          serviceEndpoints: ServiceEndpointsCosmosDB
        }
      }
      {
        name: subnetADFName
        properties: {
          addressPrefix: subnetADFPrefix
        }
      }
      {
        name: subnetKeyVaultName
        properties: {
          addressPrefix: subnetKeyVaultPrefix
          serviceEndpoints: ServiceEndpointsKeyVault
        }
      }
      {
        name: subnetDataLakeName
        properties: {
          addressPrefix: subnetDataLakePrefix
          serviceEndpoints: ServiceEndpointsDataLake
        }
      }
      {
        name: subnetFunctionsName
        properties: {
          addressPrefix: subnetFunctionsPrefix
          serviceEndpoints: ServiceEndpointsFunctions
        }
      }
      {
        name: subnetAppGWName
        properties: {
          addressPrefix: subnetAppGWPrefix
          networkSecurityGroup: {
            id: appgwnsg.id
          }
        }
      }
      {
        name: subnetSqlSrvName
        properties: {
          addressPrefix: subnetSqlSrvPrefix
        }
      }
    ]
  }
}

output functionssubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetFunctionsName)
output functionssubnetname string = subnetFunctionsName

output apimsubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetApimName)
output apimsubnetname string = subnetApimName

output cosmosdbsubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetCosmosDBName)
output cosmosdbsubnetname string = subnetCosmosDBName

output adfsubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetADFName)
output adfsubnetname string = subnetADFName

output keyvaultsubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetKeyVaultName)
output keyvaultsubnetname string = subnetKeyVaultName

output datalakesubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetDataLakeName)
output datalakesubnetname string = subnetDataLakeName

output appgwsubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetAppGWName)
output appgwsubnetname string = subnetAppGWName

output sqlsrvsubnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetSqlSrvName)
output sqlsrvsubnetname string = subnetSqlSrvName

output vnet string = vnet.id
output vnetname string = vnetName
