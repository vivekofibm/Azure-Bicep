
param serverName string = 'ou-dih-sqlserver-we'
param adminLogin string = 'dih-sa'
//@secure()
param adminPassword string = 'test@123'

param location string = resourceGroup().location




module sqlServer './sqlServer/sqlServer.bicep' = {
  name: serverName
  params: {
    location: location
    serverName: serverName
    adminLogin: adminLogin
    adminPassword: adminPassword
  }

  
}

param privateEndpointName string = 'ou-dih-test-pe-we'
param vnetName string = 'ou-dih-acct-vn-we'
param subnet string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, 'API')
param targetSubResource array =[
  'sqlServer'
]

module privateEndpoint 'privateEndpoint/privateEndpoint.bicep' = {
  name: privateEndpointName
  params: {
    privateEndpointName: privateEndpointName
    location: location
    subnetName: subnet
    targetSubResource: targetSubResource
    
  }

}

@description('Name you want to assign to DNS')
param privateDnsName string = 'privatelink.database.windows.net'

module privateDns 'privateDnsZone/privateDns.bicep' = {
  name: privateDnsName
  params: {
    privateDnsName: privateDnsName
    locations: 'global'
  }  
}

param sqlserverName string = 'ou-dih-sqlserver-we'
param databaseName string = 'sample-db1'
param dbName string = '${sqlserverName}/${databaseName}'

module sqlDb 'sqlDb/sqlDb.bicep' = {
  name: databaseName
  params: {
    dbName: dbName
    location: location
    sqlserverName: sqlserverName    
  }
  dependsOn: [
    sqlServer
  ]
  
}

param adfName string = 'ou-dih-adf-test-we'
param version string = 'V2'

module adf './ADF/adf.bicep' = {
  name: 'adf_deploy'
  params: {
    name: adfName
    version: version
    location: location
  }
}
