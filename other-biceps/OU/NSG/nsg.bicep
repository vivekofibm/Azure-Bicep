param nsgName string = 'ou-dig-nsg'
param location string = 'uksouth'
//param tags object

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: []
  }
}
