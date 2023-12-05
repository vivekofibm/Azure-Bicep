resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: 'ou-dih-acct-vn-we'
  scope: resourceGroup('rg-ou')
}

param sbnetname string = 'QAVM'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: sbnetname
  parent: virtualNetwork
  
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' existing = {
  name: 'myPublicIp'
}

resource myNetworkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'myNetworkInterface'
  location: 'uksouth'
  properties: {
    ipConfigurations: [
      {
        name: 'myIpConfiguration'
        properties: {
          subnet: {
            //id: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}/subnets/{subnetName}'
            id: subnet.id
          }
          publicIPAddress: {
            id: publicIp.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
