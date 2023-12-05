param apimName string = 'ou-dih-apim'
param location string = resourceGroup().location
param skuName string = 'Developer'
param publisherEmail string = 'vivek@mindpathtech.com'
param publisherName string = 'vivek kumar'
param vnetName string = 'ou-dih-acct-vn-we'
param subnetName string = 'API'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-11-01' existing = {
  name: subnetName
  parent: virtualNetwork
}



resource apim 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apimName
  location: location
  sku: {
    name: skuName
    capacity: 1
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: 'External'
    virtualNetworkConfiguration: {
      subnetResourceId: subnet.id
    }
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: '${apimName}.azure-api.net'
        negotiateClientCertificate: false
        defaultSslBinding: true
        certificateSource: 'BuiltIn'
      }
    ]
    backends: []
  }
}

