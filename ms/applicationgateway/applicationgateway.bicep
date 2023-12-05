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

@description('The name of the SSL certificate KeyVault Secret')
param certificateName string

@description('The managed identity name')
param identityName string

@description('The apim management backend')
param mgmt_backend_hostname string
@description('The apim backend hostname')
param apigw_backend_hostname string
@description('The apim portal hostname')
param portal_backend_hostname string

var networkInterfaceName = 'neti-appgw-dih-live'
var ipconfigName = 'ipconfig'
var publicIPAddressName = '${projectName}-appgw-${env}-pip'
var applicationGateWayName = '${projectName}-appgw-${env}'
var sslCertRef = 'https://${sslCertificateKeyVaultName}.vault.azure.net/secrets/${certificateName}'

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
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'appGwSslCertificate'
        properties: {
          keyVaultSecretId: sslCertRef
        }
      }
    ]  
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
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
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      { 
        name: 'backend-apigw'
        properties:{
          backendAddresses:[
            {
              fqdn: '10.1.0.4'
            }
          ]
        }
      }            
    ]
    backendHttpSettingsCollection: [
      {
        name: 'myHTTPSetting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'myListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateWayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateWayName, 'port_443')
          }
          firewallPolicy: {
            id: AppGW_AppFW_Pol.id
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGateWayName, 'appGwSslCertificate')
          }
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 1
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateWayName, 'myListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateWayName, 'backend-apigw')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateWayName, 'myHTTPSetting')
          }
        }
      }
    ]
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: AGWMaxCapacity
    }
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
        }
      ]
    }
  }
}

// resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = [for i in range(0, 2): {
//   name: '${networkInterfaceName}${i + 1}'
//   location: location
//   properties: {
//     ipConfigurations: [
//       {
//         name: '${ipconfigName}${i + 1}'
//         properties: {
//           privateIPAllocationMethod: 'Dynamic'
//           publicIPAddress: {
//             id: resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddressName}${i + 1}')
//           }
//           subnet: {
//             id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, backendSubnetName)
//           }
//           primary: true
//           privateIPAddressVersion: 'IPv4'
//           applicationGatewayBackendAddressPools: [
//             {
//               id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateWayName, 'backend-apigw')
//             }
//           ]
//         }
//       }
//     ]
//     enableAcceleratedNetworking: false
//     enableIPForwarding: false
//   }
// }]
