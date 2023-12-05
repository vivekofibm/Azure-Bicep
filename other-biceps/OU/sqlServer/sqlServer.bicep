param serverName string = 'ou-dih-test-we'
param adminLogin string = 'dih-sa'
//@secure()
param adminPassword string = 'test@123'

param location string = resourceGroup().location

resource server 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: serverName
  location: location

  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
}
