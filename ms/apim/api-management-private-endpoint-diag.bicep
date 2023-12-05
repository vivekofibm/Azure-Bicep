@description('The name of the API Management service instance')
param apiManagementServiceName string = 'apim-privateendpoint1-${uniqueString(resourceGroup().id)}'

@description('The email address of the owner of the service')
@minLength(4)
param publisherEmail string

@description('The name of the owner of the service')
@minLength(4)
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
param skuCount int = 1

@description('Virtual network name')
@minLength(4)
param virtualNetworkName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Private endpoint name')
@minLength(4)
param privateEndpointName string

@description('Subnet Name')
@minLength(4)
param subnetName string 

@description('eventHubAuthorizationRuleId')
@minLength(4)
param eventHubAuthorizationRuleId string

@description('eventHubName')
@minLength(4)
param eventHubName string

@description('Log Analytics WorkspaceId')
@minLength(4)
param workspaceId string

@description('A custom domain name to be used for the API Management service.')
param apiManagementCustomDnsName string

@description('A custom domain name for the API Management service developer portal (e.g., portal.consoto.com). ')
param apiManagementPortalCustomHostname string

@description('A custom domain name for the API Management service gateway/proxy endpoint (e.g., api.consoto.com).')
param apiManagementProxyCustomHostname string

@description('A custom domain name for the API Management service management portal (e.g., management.consoto.com).')
param apiManagementManagementCustomHostname string

//var privateDNSZoneName = 'privatelink.azure-api.net'

// resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' = {
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

resource apiManagementService 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apiManagementServiceName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    hostnameConfigurations: [
      {
        type: 'DeveloperPortal'
        hostName: apiManagementPortalCustomHostname
        negotiateClientCertificate: false
      }
      {
        type: 'Proxy'
        hostName: apiManagementProxyCustomHostname
        negotiateClientCertificate: false
      }
      {
        type: 'Management'
        hostName: apiManagementManagementCustomHostname
        negotiateClientCertificate: false
      }
    ]
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = {
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
          privateLinkServiceId: apiManagementService.id
          groupIds: [
            'Gateway'
          ]
        }
      }
    ]
  }
}

// resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateDNSZoneName
//   location: 'global'
//   dependsOn: [
//     virtualNetwork
//   ]
// }

// resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateDnsZones
//   name: '${privateDnsZones.name}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: resourceId('Microsoft.Network/VirtualNetworks', virtualNetworkName)
//     }
//   }
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

resource apiManagerServiceDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'apim-service-diagsettings'
  scope: apiManagementService
  properties: {
    eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
    eventHubName: eventHubName
    workspaceId: workspaceId
    logs: [
      {

        categoryGroup: 'audit'
        enabled: true
      }
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output privateEndointName string = privateEndpoint.name
