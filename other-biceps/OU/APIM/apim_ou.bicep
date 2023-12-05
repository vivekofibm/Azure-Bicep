@description('The Short Name of the Organisation. (example: ou)')
param organisationId string = 'ou'

@description('The Short Name of the Project. (example: dih)')
param projectId string = 'dih'

@description('The Name of the parent resource(example: organisationId-projectName-envName-parentName-ai-short)')
param apimParentName string = 'new'

@description('The Name of the Environment(example: dev/test/sit/prod)')
param env string = 'test'

@description('The Short name of the location (example: we,uks)')
param shortLocation string = 'we'

@description('Location where the Application Insight needs to be provisioned.')
param location string = 'west europe'

@description('The Name of the APIM we wish to give')
param apimName string = '${organisationId}-${projectId}-${env}${apimParentName}-apim-${shortLocation}'

@description('The skuName of the APIM we wish to give')
param skuName string = 'Developer'

@description('The Email of the Publisher')
param publisherEmail string = 'ds26975"open.ac.uk'

@description('The Name of the Publisher')
param publisherName string = 'Divya Singhal'

@description('The Virtual Network name we wish to attach')
param vnetName string = 'ou-dih-test-vn-we'

@description('The Subnet Name we wish to attach')
param subnetName string = 'API'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  scope: resourceGroup('ou-dih-test-rgshared-we')
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

  }
}
