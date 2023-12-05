@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string = 'constoso@contoso.com'

@description('The name of the owner of the service')
@minLength(1)
param publisherName string = 'apimPublisher'

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service. This should be a multiple of the number of availability zones getting deployed.')
param skuCount int = 1

@description('Virtual network name')
param virtualNetworkName string 

// @description('Address prefix')
// param virtualNetworkAddressPrefix string = '10.0.0.0/16'

// @description('Subnet prefix')
// param subnetPrefix string = '10.0.0.0/24'

@description('Subnet name')
param subnetName string = 'apim'

@description('Azure region where the resources will be deployed')
param location string = resourceGroup().location

@description('Numbers for availability zones, for example, 1,2,3.')
param availabilityZones array = [
  '1'
  '2'
]

@description('Name for the public IP address used to access the API Management service.')
param publicIpName string = 'myPublicIP'

@description('SKU for the public IP address used to access the API Management service.')
@allowed([
  'Standard'
])
param publicIpSku string = 'Standard'

@description('Allocation method for the Public IP address used to access the API Management service. Standard SKU public IP requires `Static` allocation.')
@allowed([
  'Static'
])
param publicIPAllocationMethod string = 'Static'

@description('Unique DNS name for the public IP address used to access the API Management service.')
param dnsLabelPrefix string = toLower('${publicIpName}-${uniqueString(resourceGroup().id)}')

@description('Name of the Apim Service')
param apiManagementName string = 'apiservice${uniqueString(resourceGroup().id)}'

@description('The apim management backend')
param mgmt_backend_hostname string
@description('The apim backend hostname')
param apigw_backend_hostname string
@description('The apim portal hostname')
param portal_backend_hostname string

@description('The managed identity name')
param identityName string

@description('The name of the SSL certificate KeyVault')
param sslCertificateKeyVaultName string

@description('The name of the SSL certificate KeyVault Secret')
param proxyCertificateName string

@description('The name of the SSL certificate KeyVault Secret')
param portalCertificateName string

@description('The name of the SSL certificate KeyVault Secret')
param managementCertificateName string

@description('eventHubAuthorizationRuleId')
@minLength(4)
param eventHubAuthorizationRuleId string

@description('eventHubName')
@minLength(4)
param eventHubName string

@description('Log Analytics WorkspaceId')
@minLength(4)
param workspaceId string

@description('App Insights Id')
param appInsightsId string

@description('App Insights InstrumentationKey')
param appInsightsInstrumentationKey string

var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var proxyKeyVaultCertificateRef = 'https://${sslCertificateKeyVaultName}.vault.azure.net/secrets/${proxyCertificateName}'
var portalKeyVaultCertificateRef = 'https://${sslCertificateKeyVaultName}.vault.azure.net/secrets/${portalCertificateName}'
var managementKeyVaultCertificateRef = 'https://${sslCertificateKeyVaultName}.vault.azure.net/secrets/${managementCertificateName}'

resource myPublicIp 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: identityName
}

resource myApim 'Microsoft.ApiManagement/service@2022-04-01-preview' = {
  name: apiManagementName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {
      }
    }
  }
  zones: ((sku == 'Premium')) ? ((length(availabilityZones) == 0) ? null : availabilityZones) : null
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: 'Internal'
    natGatewayState: 'Disabled'
    apiVersionConstraint: {
    }
    publicNetworkAccess: 'Enabled'
    publicIpAddressId: myPublicIp.id
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: apigw_backend_hostname
        negotiateClientCertificate: false
        keyVaultId: proxyKeyVaultCertificateRef
        identityClientId: userAssignedIdentity.properties.clientId
        defaultSslBinding: true
        certificateSource: 'KeyVault'
      }
      {
        type: 'DeveloperPortal'
        hostName: portal_backend_hostname
        negotiateClientCertificate: false
        keyVaultId: portalKeyVaultCertificateRef
        identityClientId: userAssignedIdentity.properties.clientId
        certificateSource: 'KeyVault'
      }
      {
        type: 'Management'
        hostName: mgmt_backend_hostname
        negotiateClientCertificate: false
        keyVaultId: managementKeyVaultCertificateRef
        identityClientId: userAssignedIdentity.properties.clientId
        certificateSource: 'KeyVault'
      }
    ]
    virtualNetworkConfiguration: {
      subnetResourceId: subnetRef
    }
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
    }
  }
}

resource apiManagerServiceDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'apim-service-diagsettings'
  scope: myApim
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

resource myApim_AppInsightsLogger 'Microsoft.ApiManagement/service/loggers@2020-12-01' = {
  parent: myApim
  name: 'AppInsightsLogger'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

resource myApim_applicationinsights 'Microsoft.ApiManagement/service/diagnostics@2020-12-01' = {
  parent: myApim
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    verbosity: 'information'
    logClientIp: true
    loggerId: myApim_AppInsightsLogger.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: {
        body: {
          bytes: 0
        }
      }
      response: {
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        body: {
          bytes: 0
        }
      }
      response: {
        body: {
          bytes: 0
        }
      }
    }
  }
}

output apimIP string = myApim.properties.privateIPAddresses[0]
output mgmt_backend_hostname string = myApim.properties.managementApiUrl
output apigw_backend_hostname string = myApim.properties.gatewayUrl 
output portal_backend_hostname string = myApim.properties.developerPortalUrl
