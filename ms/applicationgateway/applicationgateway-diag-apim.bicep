@description('Project Name')
param projectName string

@description('env')
param env string = 'dev'

@description('Location for all resources.')
param location string = resourceGroup().location

var vnetName = 'vnet-${projectName}-${env}'

@description('Virtual network backend subnet name')
param backendSubnetName string = 'myBackendSubnet'

@description('Virtual network AG subnet name')
param subnetName string = 'AppGW'

@description('Firewall Policy Name.')
param AppGW_AppFW_Pol_name string = 'myFirewallPolicy'

@description('AGW Max Capacity')
param AGWMaxCapacity int = 5

@description('The name of the SSL certificate KeyVault')
param sslCertificateKeyVaultName string

// @description('The name of the SSL certificate KeyVault Secret')
// param certificateName string

@description('The managed identity name')
param identityName string

@description('The name of the SSL certificate KeyVault Secret')
param gatewayCertificateName string

@description('The name of the SSL certificate KeyVault Secret')
param portalCertificateName string

@description('The name of the SSL certificate KeyVault Secret')
param managementCertificateName string

@description('The name of the SSL certificate KeyVault Secret')
param rootCertificateName string

@description('The apim management backend')
param mgmt_backend_hostname string
@description('The apim backend hostname')
param apigw_backend_hostname string
@description('The apim portal hostname')
param portal_backend_hostname string

@description('eventHubAuthorizationRuleId')
@minLength(4)
param eventHubAuthorizationRuleId string

@description('eventHubName')
@minLength(4)
param eventHubName string

@description('Log Analytics WorkspaceId')
@minLength(4)
param workspaceId string

var networkInterfaceName = 'neti-appgw-dih-live'
var ipconfigName = 'ipconfig'
var publicIPAddressName = '${projectName}-appgw-${env}-pip'
var applicationGateWayName = '${projectName}-appgw-${env}'
var gatewayKeyVaultCertificateRef = 'https://${sslCertificateKeyVaultName}.vault.azure.net/secrets/${gatewayCertificateName}'
var portalKeyVaultCertificateRef = 'https://${sslCertificateKeyVaultName}.vault.azure.net/secrets/${portalCertificateName}'
var managementKeyVaultCertificateRef = 'https://${sslCertificateKeyVaultName}.vault.azure.net/secrets/${managementCertificateName}'
var rootKeyVaultCertificateRef = 'https://${sslCertificateKeyVaultName}.vault.azure.net/secrets/${rootCertificateName}'

resource sslKeyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: sslCertificateKeyVaultName
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: identityName
}
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = [for i in range(0, 3): {
  name: '${publicIPAddressName}${i}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}]


resource applicationGateWay 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: applicationGateWayName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {
      }
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'gatewayIP01'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'gatewaycert'
        properties: {
          keyVaultSecretId: gatewayKeyVaultCertificateRef
        }
      }
      {
        name: 'portalcert'
        properties: {
          keyVaultSecretId: portalKeyVaultCertificateRef
        }
      }
      {
        name: 'managementcert'
        properties: {
          keyVaultSecretId: managementKeyVaultCertificateRef
        }
      }
    ]
    trustedRootCertificates: [
      {
        name: 'whitelistcert1'
        properties: {
          keyVaultSecretId: rootKeyVaultCertificateRef
        }
      }
    ]  
    frontendIPConfigurations: [
      {
        name: 'frontend1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddressName}0')
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port01'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      { 
        name: 'gatewaybackend'
        properties:{
          backendAddresses:[
            {
              fqdn: apigw_backend_hostname
            }
          ]
        }
      }
      { 
        name: 'portalbackend'
        properties:{
          backendAddresses:[
            {
              fqdn: portal_backend_hostname
            }
          ]
        }
      }
      { 
        name: 'managementbackend'
        properties:{
          backendAddresses:[
            {
              fqdn: mgmt_backend_hostname
            }
          ]
        }
      }              
    ]
    backendHttpSettingsCollection: [
      {
        name: 'apimPoolGatewaySetting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 180
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGateWayName, 'apimgatewayprobe')
          }
          trustedRootCertificates: [
            {
              id: resourceId('Microsoft.Network/applicationGateways/trustedRootCertificates', applicationGateWayName, 'whitelistcert1')
            }
          ]
        }
      }
      {
        name: 'apimPoolPortalSetting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 180
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGateWayName, 'apimportalprobe')
          }
          trustedRootCertificates: [
            {
              id: resourceId('Microsoft.Network/applicationGateways/trustedRootCertificates', applicationGateWayName, 'whitelistcert1')
            }
          ]
        }
      }
      {
        name: 'apimPoolManagementSetting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 180
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGateWayName, 'apimmanagementprobe')
          }
          trustedRootCertificates: [
            {
              id: resourceId('Microsoft.Network/applicationGateways/trustedRootCertificates', applicationGateWayName, 'whitelistcert1')
            }
          ]
        }
      }
    ]
    httpListeners: [
      {
        name: 'gatewaylistener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateWayName, 'frontend1')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateWayName, 'port01')
          }
          firewallPolicy: {
            id: AppGW_AppFW_Pol.id
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGateWayName, 'gatewaycert')
          }
          hostName: apigw_backend_hostname
          hostNames: []
          requireServerNameIndication: true
          customErrorConfigurations: []
        }
      }
      {
        name: 'portallistener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateWayName, 'frontend1')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateWayName, 'port01')
          }
          firewallPolicy: {
            id: AppGW_AppFW_Pol.id
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGateWayName, 'portalcert')
          }
          hostName: portal_backend_hostname
          hostNames: []
          requireServerNameIndication: true
          customErrorConfigurations: []
        }
      }
      {
        name: 'managementlistener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateWayName, 'frontend1')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateWayName, 'port01')
          }
          firewallPolicy: {
            id: AppGW_AppFW_Pol.id
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGateWayName, 'managementcert')
          }
          hostName: mgmt_backend_hostname
          hostNames: []
          requireServerNameIndication: true
          customErrorConfigurations: []
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'gatewayrule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id:  resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateWayName, 'gatewaylistener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateWayName, 'gatewaybackend')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateWayName, 'apimPoolGatewaySetting')
          }
        }
      }
      {
        name: 'portalrule'
        properties: {
          ruleType: 'Basic'
          priority: 120
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateWayName, 'portallistener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateWayName, 'portalbackend')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateWayName, 'apimPoolPortalSetting')
          }
        }
      }
      {
        name: 'managementrule'
        properties: {
          ruleType: 'Basic'
          priority: 140
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateWayName, 'managementlistener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateWayName, 'managementbackend')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateWayName, 'apimPoolManagementSetting')
          }
        }
      }
    ]
    probes: [
      {
        name: 'apimgatewayprobe'
        properties: {
          protocol: 'Https'
          host: apigw_backend_hostname
          path: '/status-0123456789abcdef'
          interval: 30
          timeout: 120
          unhealthyThreshold: 8
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
          }
        }
      }
      {
        name: 'apimportalprobe'
        properties: {
          protocol: 'Https'
          host: portal_backend_hostname
          path: '/signin'
          interval: 60
          timeout: 300
          unhealthyThreshold: 8
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
          }
        }
      }
      {
        name: 'apimmanagementprobe'
        properties: {
          protocol: 'Https'
          host: mgmt_backend_hostname
          path: '/ServiceStatus'
          interval: 60
          timeout: 300
          unhealthyThreshold: 8
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
          }
        }
      }
    ]
    enableHttp2: false
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.1'
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      
    }
    firewallPolicy: {
      id: AppGW_AppFW_Pol.id
    }
  }
  dependsOn: [
    publicIPAddress[0]
  ]
}

resource AppGW_AppFW_Pol 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-08-01' = {
  name: AppGW_AppFW_Pol_name
  location: location
  properties: {
    customRules: [
      {
        name: 'CustRule01'
        priority: 100
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: true
            matchValues: [
              '10.10.10.0/24'
            ]
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942200'
                  state: 'Disabled'
                }
              ]
            }
          ]
        }
      ]
    }
  }
}


resource appGatewayDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'appGw-diagsettings'
  scope: applicationGateWay 
  properties: {
    eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
    eventHubName: eventHubName
    workspaceId: workspaceId
    logs: [
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
