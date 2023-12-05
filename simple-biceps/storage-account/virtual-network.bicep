@decription('Provide a name of virtual network')
param vnetName string = 'my-test-vnet'  //it we are not passing the value, it will take this default name

@description('pass the location where you want to create the resource')
param location string = resourceGroup().location  //By default it will take the resource group location

@decription('Provide a name of subnet')
param subnetName string = 'my-test-subnet'  //it we are not passing the value, it will take this default name



resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.101.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.101.1.0/24'
          // delegations: [
          //   {
          //     name: 'Microsoft.Web/serverFarms'
          //     properties: {
          //       serviceName: 'Microsoft.Web/serverFarms'
          //     }
          //   }
          // ]
        }
      }
    ]
  }
}
