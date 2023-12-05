param vnetName string = 'ou-dih-acct-vn-we'
param subnetName string = 'API'
param subnetApimPrefix string = '10.103.0.0/24'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: vnetName
  //scope: resourceGroup('ou-dih-test-rgshared-we')
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: 'ou-dig-nsg'
}

resource subnetApi 'Microsoft.Network/virtualNetworks/subnets@2022-11-01'  = {
  parent: virtualNetwork
  name: subnetName
  properties: {
    addressPrefix: subnetApimPrefix
    networkSecurityGroup: {
      id: nsg.id
    }

  }
  
  
}

